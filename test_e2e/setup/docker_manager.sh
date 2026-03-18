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
    echo "Resetting database (dropping all data)..."
    # Drop and recreate the database inside the running postgres container
    if ! docker compose -f "$BACKEND_DIR/docker-compose.yaml" exec -T postgres pg_isready -U postgres > /dev/null 2>&1; then
      echo "ERROR: PostgreSQL is not running. Start it first with: $0 up"
      exit 1
    fi
    docker compose -f "$BACKEND_DIR/docker-compose.yaml" exec -T postgres \
      psql -U postgres -c "DROP DATABASE IF EXISTS flutter_cms_be;"
    docker compose -f "$BACKEND_DIR/docker-compose.yaml" exec -T postgres \
      psql -U postgres -c "CREATE DATABASE flutter_cms_be OWNER postgres;"
    echo "Database reset. Restart the server with server_manager.sh to re-apply migrations."
    ;;
  *)
    echo "Usage: $0 {up|down|reset}"
    exit 1
    ;;
esac
