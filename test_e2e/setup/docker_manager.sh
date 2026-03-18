#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../../../flutter_cms_be/flutter_cms_be_server"

if [ ! -f "$BACKEND_DIR/docker-compose.yaml" ]; then
  echo "ERROR: Backend docker-compose.yaml not found at $BACKEND_DIR"
  echo "Expected workspace layout: flutter_cms_workspace/{flutter_cms, flutter_cms_be}"
  exit 1
fi

case "$1" in
  up)
    echo "Starting Docker services..."
    docker compose -f "$BACKEND_DIR/docker-compose.yaml" up -d postgres redis
    echo "Waiting for PostgreSQL (port 8090)..."
    RETRIES=30
    until docker compose -f "$BACKEND_DIR/docker-compose.yaml" exec -T postgres pg_isready -U postgres > /dev/null 2>&1; do
      RETRIES=$((RETRIES - 1))
      if [ $RETRIES -le 0 ]; then
        echo "ERROR: PostgreSQL did not become ready in time."
        exit 1
      fi
      sleep 1
    done
    echo "Test services ready."
    ;;
  down)
    echo "Stopping Docker services..."
    docker compose -f "$BACKEND_DIR/docker-compose.yaml" down
    echo "Services stopped."
    ;;
  reset)
    echo "Cleaning up E2E test data (preserving clients, users, tokens)..."
    if ! docker compose -f "$BACKEND_DIR/docker-compose.yaml" exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
      echo "ERROR: PostgreSQL is not running. Start it first with: $0 up"
      exit 1
    fi
    # Truncate document/version/media tables, preserve client/user/token tables.
    # Order matters: child tables first due to foreign key constraints.
    docker compose -f "$BACKEND_DIR/docker-compose.yaml" exec -T postgres \
      psql -U postgres -d flutter_cms_be -c "
        TRUNCATE
          document_crdt_operations,
          document_crdt_snapshots,
          document_versions,
          cms_documents_data,
          cms_documents,
          media_files
        CASCADE;
      "
    echo "Done. Documents, versions, CRDT data, and media cleared. Clients, users, and tokens preserved."
    ;;
  *)
    echo "Usage: $0 {up|down|reset}"
    exit 1
    ;;
esac
