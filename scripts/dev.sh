#!/usr/bin/env sh

set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
BACKEND_PORT="${BACKEND_PORT:-8081}"
FRONTEND_PORT="${FRONTEND_PORT:-3001}"

backend_pid=""
frontend_pid=""

cleanup() {
  if [ -n "$frontend_pid" ] && kill -0 "$frontend_pid" 2>/dev/null; then
    kill "$frontend_pid" 2>/dev/null || true
    wait "$frontend_pid" 2>/dev/null || true
  fi

  if [ -n "$backend_pid" ] && kill -0 "$backend_pid" 2>/dev/null; then
    kill "$backend_pid" 2>/dev/null || true
    wait "$backend_pid" 2>/dev/null || true
  fi

}

trap cleanup INT TERM HUP

echo "Starting backend on http://localhost:${BACKEND_PORT}"
(cd "$ROOT_DIR" && go run ./cmd/memos --port "$BACKEND_PORT") &
backend_pid=$!

echo "Starting frontend on http://localhost:${FRONTEND_PORT}"
(cd "$ROOT_DIR/web" && pnpm exec vite --host 0.0.0.0 --port "$FRONTEND_PORT") &
frontend_pid=$!

echo "Both dev servers are starting. Press Ctrl+C to stop them together."

wait "$backend_pid" "$frontend_pid"
cleanup
