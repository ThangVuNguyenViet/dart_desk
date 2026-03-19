#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../../../flutter_cms_be/flutter_cms_be_server"

if [ ! -f "$BACKEND_DIR/docker-compose.yaml" ]; then
  echo "ERROR: Backend docker-compose.yaml not found at $BACKEND_DIR"
  exit 1
fi

echo "=== Seeding E2E Test Data ==="

# Test tokens (deterministic, safe for E2E only)
TOKEN_A="cms_ad_e2eTestTokenClientA000000000000000aaaa"
TOKEN_B="cms_ad_e2eTestTokenClientB000000000000000bbbb"

# Pre-computed bcrypt hashes of the tokens above
HASH_A='$2b$10$Z0kp3lgBwCTj.bhCovYR6uztc7xOZ3HradOvzOlp1eBPBOaMJE3BC'
HASH_B='$2b$10$I3p3Gw9cGKGSFbr8qDU2kuskI/T.8CAi5QpIOIOEZx04CZiHPzLcC'

docker compose -f "$BACKEND_DIR/docker-compose.yaml" exec -T postgres \
  psql -U postgres -d flutter_cms_be -c "
    -- Seed Client A
    INSERT INTO cms_clients (name, slug, \"apiTokenHash\", \"apiTokenPrefix\", \"isActive\", \"createdAt\", \"updatedAt\")
    VALUES ('E2E Client A', 'e2e-client-a', '$HASH_A', 'cms_ad_', true, NOW(), NOW())
    ON CONFLICT (slug) DO NOTHING;

    -- Seed Client B
    INSERT INTO cms_clients (name, slug, \"apiTokenHash\", \"apiTokenPrefix\", \"isActive\", \"createdAt\", \"updatedAt\")
    VALUES ('E2E Client B', 'e2e-client-b', '$HASH_B', 'cms_ad_', true, NOW(), NOW())
    ON CONFLICT (slug) DO NOTHING;

    -- Seed API token for Client A
    INSERT INTO cms_api_tokens (\"clientId\", name, \"tokenHash\", \"tokenPrefix\", \"tokenSuffix\", role, \"isActive\", \"createdAt\")
    SELECT id, 'E2E Admin Token', '$HASH_A', 'cms_ad_', 'aaaa', 'admin', true, NOW()
    FROM cms_clients WHERE slug = 'e2e-client-a'
    ON CONFLICT (\"clientId\", \"tokenPrefix\", \"tokenSuffix\") DO NOTHING;

    -- Seed API token for Client B
    INSERT INTO cms_api_tokens (\"clientId\", name, \"tokenHash\", \"tokenPrefix\", \"tokenSuffix\", role, \"isActive\", \"createdAt\")
    SELECT id, 'E2E Admin Token', '$HASH_B', 'cms_ad_', 'bbbb', 'admin', true, NOW()
    FROM cms_clients WHERE slug = 'e2e-client-b'
    ON CONFLICT (\"clientId\", \"tokenPrefix\", \"tokenSuffix\") DO NOTHING;
  "

echo ""
echo "E2E seed data ready."
echo "  Client A: slug=e2e-client-a token=$TOKEN_A"
echo "  Client B: slug=e2e-client-b token=$TOKEN_B"
echo ""
echo "=== Seed complete ==="
