#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)/../dart_desk_be/dart_desk_server"
COMPOSE_FILE="$BACKEND_DIR/docker-compose.yaml"
PID_FILE="/tmp/dart_desk_e2e_server.pid"
LOG_FILE="/tmp/dart_desk_e2e_server.log"

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "ERROR: docker-compose.yaml not found at $BACKEND_DIR"
  echo "Expected workspace layout: dart_desk_workspace/{dart_desk, dart_desk_be}"
  exit 1
fi

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
    echo "Server stopped."
  fi
}

start_server() {
  if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
    echo "Server already running (PID: $(cat "$PID_FILE"))"
    return
  fi

  echo "Starting Serverpod E2E server (mode=e2e, port 8080, test DB on 9090)..."
  cd "$BACKEND_DIR"
  dart run bin/main.dart --apply-migrations --role=monolith --mode=e2e > "$LOG_FILE" 2>&1 &
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

reset_db() {
  echo "Resetting test database to clean state..."
  if ! docker compose -f "$COMPOSE_FILE" exec -T postgres_test pg_isready -U postgres > /dev/null 2>&1; then
    echo "ERROR: Test PostgreSQL is not running. Run '$0 up' first."
    exit 1
  fi
  docker compose -f "$COMPOSE_FILE" exec -T postgres_test \
    psql -U postgres -d dart_desk_be_test -c "
      TRUNCATE
        document_crdt_operations,
        document_crdt_snapshots,
        document_versions,
        documents_data,
        documents,
        media_assets,
        api_tokens,
        users,
        projects,
        deployments,
        serverpod_auth_core_jwt_refresh_token,
        serverpod_auth_core_profile,
        serverpod_auth_core_profile_image,
        serverpod_auth_core_session,
        serverpod_auth_idp_email_account,
        serverpod_auth_idp_email_account_password_reset_request,
        serverpod_auth_idp_email_account_request,
        serverpod_auth_idp_google_account,
        serverpod_auth_core_user
      CASCADE;
    "
  echo "Done. All app and auth data cleared."
}

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
  restart)
    stop_server
    reset_db
    start_server
    ;;
  seed)
    echo "Seeding E2E auth user..."
    bash "$SCRIPT_DIR/seed_data.sh"
    ;;
  *)
    echo "Usage: $0 {up|down|reset|restart|seed}"
    echo ""
    echo "  up       Start test DB + Redis + Serverpod server"
    echo "  down     Stop server + test DB + Redis"
    echo "  reset    Truncate all test DB tables (clean slate)"
    echo "  restart  Stop server, reset DB, start server"
    echo "  seed     Seed auth user for tests that skip registration"
    exit 1
    ;;
esac
