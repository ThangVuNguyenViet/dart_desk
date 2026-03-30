#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)/../dart_desk_be/dart_desk_server"
COMPOSE_FILE="$BACKEND_DIR/docker-compose.yaml"
PID_FILE="/tmp/dart_desk_e2e_server.pid"
LOG_FILE="/tmp/dart_desk_e2e_server.log"

DB_CMD="PGPASSWORD=dart_desk_be_test_password psql -h localhost -p 9090 -U postgres -d dart_desk_be_test"

E2E_PROJECT_SLUG="e2e-dart-desk-project"
E2E_EMAIL="e2e@dartdesk.dev"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "ERROR: docker-compose.yaml not found at $BACKEND_DIR"
  echo "Expected workspace layout: dart_desk_workspace/{dart_desk, dart_desk_be}"
  exit 1
fi

# ---------------------------------------------------------------------------
# Server lifecycle
# ---------------------------------------------------------------------------

stop_server() {
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    echo "Stopping server (PID: $PID)..."
    kill "$PID" 2>/dev/null || true
    for i in $(seq 1 10); do
      if ! kill -0 "$PID" 2>/dev/null; then break; fi
      sleep 1
    done
    kill -9 "$PID" 2>/dev/null || true
    rm -f "$PID_FILE"
    # Restore original test.yaml if backup exists
    if [ -f "$BACKEND_DIR/config/test.yaml.bak" ]; then
      mv "$BACKEND_DIR/config/test.yaml.bak" "$BACKEND_DIR/config/test.yaml"
    fi
    echo "Server stopped."
  fi
}

start_server() {
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "Server already running (PID: $(cat "$PID_FILE"))"
    return
  fi

  echo "Starting Serverpod E2E server (mode=test, port 8080, test DB on 9090)..."
  cd "$BACKEND_DIR"
  # Serverpod only allows development/test/staging/production modes.
  # Swap test.yaml with e2e.yaml for fixed-port E2E testing.
  cp config/test.yaml config/test.yaml.bak
  cp config/e2e.yaml config/test.yaml
  dart run bin/main.dart --apply-migrations --role=monolith --mode=test > "$LOG_FILE" 2>&1 &
  SERVER_PID=$!
  echo $SERVER_PID > "$PID_FILE"

  echo "Waiting for server to be ready..."
  RETRIES=60
  until curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/ 2>/dev/null | grep -q -E "^[0-9]"; do
    RETRIES=$((RETRIES - 1))
    if [ $RETRIES -le 0 ]; then
      echo "ERROR: Server did not become ready in time."
      kill $SERVER_PID 2>/dev/null || true
      rm -f "$PID_FILE"
      exit 1
    fi
    if ! kill -0 $SERVER_PID 2>/dev/null; then
      echo "ERROR: Server process died during startup."
      rm -f "$PID_FILE"
      exit 1
    fi
    sleep 1
  done
  echo "Server ready at http://localhost:8080"
}

# ---------------------------------------------------------------------------
# Database helpers
# ---------------------------------------------------------------------------

ensure_db_running() {
  if ! docker compose -f "$COMPOSE_FILE" exec -T postgres_test pg_isready -U postgres > /dev/null 2>&1; then
    echo "ERROR: Test PostgreSQL is not running. Run '$0 up' first."
    exit 1
  fi
}

run_sql() {
  docker compose -f "$COMPOSE_FILE" exec -T postgres_test \
    psql -U postgres -d dart_desk_be_test -c "$1"
}

# ---------------------------------------------------------------------------
# reset: Truncate CMS content tables ONLY (preserves users, projects, auth)
# ---------------------------------------------------------------------------

reset_db() {
  echo "Resetting CMS content for project '$E2E_PROJECT_SLUG' only..."
  ensure_db_running
  run_sql "
    DELETE FROM document_crdt_operations
    USING documents d, projects p
    WHERE document_crdt_operations.\"documentId\" = d.id
      AND d.\"projectId\" = p.id
      AND p.slug = '$E2E_PROJECT_SLUG';

    DELETE FROM document_crdt_snapshots
    USING documents d, projects p
    WHERE document_crdt_snapshots.\"documentId\" = d.id
      AND d.\"projectId\" = p.id
      AND p.slug = '$E2E_PROJECT_SLUG';

    DELETE FROM documents_data
    USING users u
    WHERE documents_data.\"createdByUserId\" = u.id
      AND u.email = '$E2E_EMAIL';

    DELETE FROM document_versions
    USING documents d, projects p
    WHERE document_versions.\"documentId\" = d.id
      AND d.\"projectId\" = p.id
      AND p.slug = '$E2E_PROJECT_SLUG';

    DELETE FROM documents
    USING projects p
    WHERE documents.\"projectId\" = p.id
      AND p.slug = '$E2E_PROJECT_SLUG';

    DELETE FROM media_assets
    USING projects p
    WHERE media_assets.\"projectId\" = p.id
      AND p.slug = '$E2E_PROJECT_SLUG';
  "
  echo "Done. CMS content cleared for '$E2E_PROJECT_SLUG'; other projects, users, auth preserved."
}

# ---------------------------------------------------------------------------
# seed: Idempotent — ensures E2E user, project, and API token exist
# ---------------------------------------------------------------------------

seed_db() {
  echo "Seeding E2E data..."
  ensure_db_running

  local SERVER_URL="http://localhost:8080"
  local E2E_EMAIL="e2e@dartdesk.dev"
  local E2E_PASSWORD="e2e-password-123"
  local E2E_CLIENT_SLUG="e2e-dart-desk-client"

  # API token: plaintext is "cms_w_e2eTestTokenForDartDeskIntegration00aaaa"
  # Validated by ApiKeyValidator which uses SHA-256 hash + prefix/suffix lookup.
  local E2E_TOKEN_PREFIX="cms_w_"
  local E2E_TOKEN_SUFFIX="aaaa"
  local E2E_TOKEN_HASH="2aa123a468fd6e4e815baf6883b4c09acb40f0899061f6e457fe1b9d0ecd7924"
  local E2E_TOKEN_PLAINTEXT="cms_w_e2eTestTokenForDartDeskIntegration00aaaa"

  # Check if the user already exists (idempotent)
  local EXISTING
  EXISTING=$(run_sql "SELECT count(*) FROM serverpod_auth_idp_email_account WHERE email = '$E2E_EMAIL'" 2>/dev/null | grep -oE '[0-9]+' | head -1)
  if [ "$EXISTING" = "1" ]; then
    echo "Auth user $E2E_EMAIL already exists, skipping registration."
  else
    echo "Registering $E2E_EMAIL via Serverpod email IDP..."

    # Serverpod uses Argon2id with a server-side pepper, so we must register
    # through the API rather than inserting a hash directly.
    # Flow: startRegistration → grab verification code from server log → verifyRegistrationCode → finishRegistration

    # Wait for server to be ready
    if ! curl -s -o /dev/null "$SERVER_URL/" 2>/dev/null; then
      echo "ERROR: Server not running at $SERVER_URL. Run '$0 up' first."
      exit 1
    fi

    # Step 1: Start registration
    local ACCOUNT_REQUEST_ID
    ACCOUNT_REQUEST_ID=$(curl -sf -X POST "$SERVER_URL/emailIdp/startRegistration" \
      -H "Content-Type: application/json" \
      -d "{\"email\":\"$E2E_EMAIL\"}" | tr -d '"')

    if [ -z "$ACCOUNT_REQUEST_ID" ]; then
      echo "ERROR: startRegistration failed."
      exit 1
    fi
    echo "  Account request: $ACCOUNT_REQUEST_ID"
    sleep 1

    # Step 2: Read verification code from server log
    local VERIFICATION_CODE
    VERIFICATION_CODE=$(tail -30 "$LOG_FILE" | grep "Registration code ($E2E_EMAIL)" | tail -1 | grep -oE '[0-9]{8}' | tail -1)

    if [ -z "$VERIFICATION_CODE" ]; then
      echo "ERROR: Could not find verification code in $LOG_FILE"
      exit 1
    fi
    echo "  Verification code: $VERIFICATION_CODE"

    # Step 3: Verify registration code → get registration token
    local REGISTRATION_TOKEN
    REGISTRATION_TOKEN=$(curl -sf -X POST "$SERVER_URL/emailIdp/verifyRegistrationCode" \
      -H "Content-Type: application/json" \
      -d "{\"accountRequestId\":\"$ACCOUNT_REQUEST_ID\",\"verificationCode\":\"$VERIFICATION_CODE\"}" | tr -d '"')

    if [ -z "$REGISTRATION_TOKEN" ]; then
      echo "ERROR: verifyRegistrationCode failed."
      exit 1
    fi

    # Step 4: Finish registration with password
    local FINISH_RESULT
    FINISH_RESULT=$(curl -sf -X POST "$SERVER_URL/emailIdp/finishRegistration" \
      -H "Content-Type: application/json" \
      -d "{\"registrationToken\":\"$REGISTRATION_TOKEN\",\"password\":\"$E2E_PASSWORD\"}")

    if [ -z "$FINISH_RESULT" ]; then
      echo "ERROR: finishRegistration failed."
      exit 1
    fi
    echo "  User registered successfully."
  fi

  # Ensure app-level user + API token exist (SQL, idempotent)
  local AUTH_USER_ID
  AUTH_USER_ID=$(run_sql "SELECT \"authUserId\" FROM serverpod_auth_idp_email_account WHERE email = '$E2E_EMAIL'" 2>/dev/null | grep -oE '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}' | head -1)

  if [ -z "$AUTH_USER_ID" ]; then
    echo "ERROR: Could not find auth user ID for $E2E_EMAIL"
    exit 1
  fi

  run_sql "
    INSERT INTO clients (name, slug, \"isActive\", \"createdAt\", \"updatedAt\")
    SELECT 'Dart Desk E2E Client', '$E2E_CLIENT_SLUG', true, NOW(), NOW()
    WHERE NOT EXISTS (
      SELECT 1 FROM clients WHERE slug = '$E2E_CLIENT_SLUG'
    );

    INSERT INTO projects (\"clientId\", name, slug, \"isActive\", \"createdAt\", \"updatedAt\")
    SELECT c.id, 'Dart Desk E2E Project', '$E2E_PROJECT_SLUG', true, NOW(), NOW()
    FROM clients c
    WHERE c.slug = '$E2E_CLIENT_SLUG'
      AND NOT EXISTS (
        SELECT 1 FROM projects WHERE slug = '$E2E_PROJECT_SLUG'
      );

    UPDATE users
    SET \"clientId\" = c.id,
        email = '$E2E_EMAIL',
        name = 'E2E Test User',
        role = 'admin',
        \"isActive\" = true,
        \"updatedAt\" = NOW()
    FROM clients c
    WHERE c.slug = '$E2E_CLIENT_SLUG'
      AND users.\"serverpodUserId\" = '$AUTH_USER_ID';

    INSERT INTO users (\"clientId\", \"serverpodUserId\", email, name, role, \"isActive\", \"createdAt\", \"updatedAt\")
    SELECT c.id, '$AUTH_USER_ID', '$E2E_EMAIL', 'E2E Test User', 'admin', true, NOW(), NOW()
    FROM clients c
    WHERE c.slug = '$E2E_CLIENT_SLUG'
      AND NOT EXISTS (
        SELECT 1 FROM users WHERE \"serverpodUserId\" = '$AUTH_USER_ID'
      );

    DELETE FROM api_tokens
    WHERE \"tokenPrefix\" = '$E2E_TOKEN_PREFIX'
      AND \"tokenSuffix\" = '$E2E_TOKEN_SUFFIX'
      AND \"projectId\" <> (
        SELECT id FROM projects WHERE slug = '$E2E_PROJECT_SLUG' LIMIT 1
      );

    INSERT INTO api_tokens (\"projectId\", name, \"tokenHash\", \"tokenPrefix\", \"tokenSuffix\", role, \"isActive\",
                            \"createdByUserId\", \"createdAt\")
    SELECT p.id,
           'E2E Write Token',
           '$E2E_TOKEN_HASH',
           '$E2E_TOKEN_PREFIX',
           '$E2E_TOKEN_SUFFIX',
           'write',
           true,
           u.id,
           NOW()
    FROM projects p
    JOIN users u ON u.\"serverpodUserId\" = '$AUTH_USER_ID'
    WHERE p.slug = '$E2E_PROJECT_SLUG'
      AND NOT EXISTS (
        SELECT 1 FROM api_tokens t
        WHERE t.\"projectId\" = p.id
          AND t.\"tokenPrefix\" = '$E2E_TOKEN_PREFIX'
          AND t.\"tokenSuffix\" = '$E2E_TOKEN_SUFFIX'
      );
  "

  echo "Seed complete."
  echo "  Login : email=$E2E_EMAIL  password=$E2E_PASSWORD"
  echo "  Token : $E2E_TOKEN_PLAINTEXT"
}


# ---------------------------------------------------------------------------
# Commands
# ---------------------------------------------------------------------------

case "$1" in
  up)
    echo "Starting test Docker services..."
    docker compose -f "$COMPOSE_FILE" up -d postgres_test redis_test
    echo "Waiting for PostgreSQL (port 9090)..."
    RETRIES=30
    until docker compose -f "$COMPOSE_FILE" exec -T postgres_test pg_isready -U postgres > /dev/null 2>&1; do
      RETRIES=$((RETRIES - 1))
      if [ $RETRIES -le 0 ]; then
        echo "ERROR: PostgreSQL did not become ready in time."
        exit 1
      fi
      sleep 1
    done
    echo "Test services ready."
    start_server
    ;;
  down)
    stop_server
    echo "Stopping test Docker services..."
    docker compose -f "$COMPOSE_FILE" stop postgres_test redis_test
    echo "All stopped."
    ;;
  reset)
    reset_db
    ;;
  seed)
    seed_db
    ;;
  restart)
    stop_server
    reset_db
    start_server
    ;;
  *)
    echo "Usage: $0 {up|down|reset|seed|restart}"
    echo ""
    echo "  up         Start test DB + Redis + Serverpod server"
    echo "  down       Stop server + test DB + Redis"
    echo "  reset      Truncate CMS content tables (preserves users/projects/auth)"
    echo "  seed       Ensure E2E user, project, and API token exist (idempotent)"
    echo "  restart    down + reset + up"
    exit 1
    ;;
esac
