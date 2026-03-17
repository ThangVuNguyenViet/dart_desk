#!/bin/bash
set -e

SERVER_URL="${1:-http://localhost:8080}"

echo "=== Seeding E2E Test Data ==="
echo "Server: $SERVER_URL"
echo ""

# NOTE: This seed script is a placeholder.
# Once the CmsClient and CmsApiToken endpoint contracts are finalized,
# this should be replaced with a Dart script run from within the backend
# project directory (for proper package resolution).
#
# For now, seed data manually:
echo "NOTE: seed_data.sh is a placeholder."
echo ""
echo "To seed E2E data manually:"
echo "1. Start the E2E server (server_manager.sh start)"
echo "2. Use the app login/setup flow to create a client"
echo "3. Note the client slug and API token for the Flutter app"
echo ""
echo "TODO: Automate this by running a Dart seed script from"
echo "      the flutter_cms_be_server directory with proper package resolution."

echo ""
echo "=== Seed complete ==="
