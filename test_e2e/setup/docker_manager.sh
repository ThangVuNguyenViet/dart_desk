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
    echo "Starting test Docker services..."
    docker compose -f "$BACKEND_DIR/docker-compose.yaml" up -d postgres_test redis_test
    echo "Waiting for PostgreSQL (port 9090)..."
    RETRIES=30
    until docker compose -f "$BACKEND_DIR/docker-compose.yaml" exec -T postgres_test pg_isready -U postgres > /dev/null 2>&1; do
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
    echo "Stopping test Docker services..."
    docker compose -f "$BACKEND_DIR/docker-compose.yaml" down
    echo "Services stopped."
    ;;
  *)
    echo "Usage: $0 {up|down}"
    exit 1
    ;;
esac
