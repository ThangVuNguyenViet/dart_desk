#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel)/../dart_desk_be/dart_desk_server"

if [ ! -f "$BACKEND_DIR/docker-compose.yaml" ]; then
  echo "ERROR: Backend docker-compose.yaml not found at $BACKEND_DIR"
  exit 1
fi

echo "=== Seeding E2E Auth User ==="

# Pre-computed bcrypt hash of "e2e-password-123"
E2E_AUTH_USER_ID="00000000-0000-7000-8000-e2e000000001"
E2E_PWD_HASH='$2b$10$E6ICM474gY5FtSV2mLwaK.qLuz1F9RfVWEgzjT.oeDKdPDjUM3TJS'

docker compose -f "$BACKEND_DIR/docker-compose.yaml" exec -T postgres_test \
  psql -U postgres -d dart_desk_be_test -c "
    INSERT INTO serverpod_auth_core_user (id, \"createdAt\", \"scopeNames\", blocked)
    VALUES ('$E2E_AUTH_USER_ID', NOW(), '[\"admin\"]', false)
    ON CONFLICT (id) DO NOTHING;

    INSERT INTO serverpod_auth_idp_email_account (\"authUserId\", \"createdAt\", email, \"passwordHash\")
    VALUES ('$E2E_AUTH_USER_ID', NOW(), 'e2e@dartdesk.dev', '$E2E_PWD_HASH')
    ON CONFLICT (email) DO NOTHING;
  "

echo ""
echo "E2E auth user ready."
echo "  Login: email=e2e@dartdesk.dev password=e2e-password-123"
echo ""
echo "=== Seed complete ==="
