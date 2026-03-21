#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../../../dart_desk_be/dart_desk_be_server"

if [ ! -f "$BACKEND_DIR/docker-compose.yaml" ]; then
  echo "ERROR: Backend docker-compose.yaml not found at $BACKEND_DIR"
  exit 1
fi

echo "=== Seeding E2E Test Data ==="

# Test API token (deterministic, safe for E2E only)
TOKEN="cms_ad_e2eTestTokenSingleTenant00000000aaaa"

# Pre-computed bcrypt hash of the token above
TOKEN_HASH='$2b$10$Z0kp3lgBwCTj.bhCovYR6uztc7xOZ3HradOvzOlp1eBPBOaMJE3BC'

# -----------------------------------------------------------------------
# Serverpod auth user for E2E login
# -----------------------------------------------------------------------
E2E_AUTH_USER_ID="00000000-0000-7000-8000-e2e000000001"
# Pre-computed bcrypt hash of "e2e-password-123"
E2E_PWD_HASH='$2b$10$E6ICM474gY5FtSV2mLwaK.qLuz1F9RfVWEgzjT.oeDKdPDjUM3TJS'

docker compose -f "$BACKEND_DIR/docker-compose.yaml" exec -T postgres \
  psql -U postgres -d dart_desk_be -c "
    -- Seed Serverpod core auth user (FK parent)
    INSERT INTO serverpod_auth_core_user (id, \"createdAt\", \"scopeNames\", blocked)
    VALUES ('$E2E_AUTH_USER_ID', NOW(), '[\"admin\"]', false)
    ON CONFLICT (id) DO NOTHING;

    -- Seed Serverpod auth email account for E2E login
    INSERT INTO serverpod_auth_idp_email_account (\"authUserId\", \"createdAt\", email, \"passwordHash\")
    VALUES ('$E2E_AUTH_USER_ID', NOW(), 'e2e@dartdesk.dev', '$E2E_PWD_HASH')
    ON CONFLICT (email) DO NOTHING;

    -- Seed User record (single-tenant: tenantId = NULL)
    INSERT INTO users (\"tenantId\", email, name, role, \"isActive\", \"serverpodUserId\", \"createdAt\", \"updatedAt\")
    VALUES (NULL, 'e2e@dartdesk.dev', 'E2E Admin', 'admin', true, '$E2E_AUTH_USER_ID', NOW(), NOW())
    ON CONFLICT (\"tenantId\", email) DO NOTHING;

    -- Seed API token (single-tenant: tenantId = NULL)
    INSERT INTO api_tokens (\"tenantId\", name, \"tokenHash\", \"tokenPrefix\", \"tokenSuffix\", role, \"isActive\", \"createdAt\")
    VALUES (NULL, 'E2E Admin Token', '$TOKEN_HASH', 'cms_ad_', 'aaaa', 'admin', true, NOW())
    ON CONFLICT (\"tenantId\", \"tokenPrefix\", \"tokenSuffix\") DO NOTHING;
  "

echo ""
echo "E2E seed data ready."
echo "  Login: email=e2e@dartdesk.dev password=e2e-password-123"
echo "  API Token: $TOKEN"
echo ""
echo "=== Seed complete ==="
