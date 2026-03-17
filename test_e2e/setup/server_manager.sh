#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKEND_DIR="$SCRIPT_DIR/../../../flutter_cms_be/flutter_cms_be_server"
PID_FILE="/tmp/flutter_cms_e2e_server.pid"

if [ ! -f "$BACKEND_DIR/bin/main.dart" ]; then
  echo "ERROR: Backend main.dart not found at $BACKEND_DIR"
  exit 1
fi

case "$1" in
  start)
    if [ -f "$PID_FILE" ] && kill -0 "$(cat $PID_FILE)" 2>/dev/null; then
      echo "Server already running (PID: $(cat $PID_FILE))"
      exit 0
    fi

    echo "Starting Serverpod E2E server on port 8080..."
    cd "$BACKEND_DIR"
    dart run bin/main.dart --apply-migrations --role=monolith --mode=e2e &
    SERVER_PID=$!
    echo $SERVER_PID > "$PID_FILE"
    echo "Server PID: $SERVER_PID"

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
    ;;
  stop)
    if [ -f "$PID_FILE" ]; then
      PID=$(cat "$PID_FILE")
      echo "Stopping server (PID: $PID)..."
      kill "$PID" 2>/dev/null || true
      for i in $(seq 1 10); do
        if ! kill -0 "$PID" 2>/dev/null; then
          break
        fi
        sleep 1
      done
      kill -9 "$PID" 2>/dev/null || true
      rm -f "$PID_FILE"
      echo "Server stopped."
    else
      echo "No server PID file found at $PID_FILE"
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
