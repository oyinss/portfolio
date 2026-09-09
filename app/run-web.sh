#!/usr/bin/env bash
# Start the portfolio web app (live API). Run from anywhere: ./run-web.sh [port]
set -e
PORT="${1:-8091}"
cd "$(dirname "$0")"
exec flutter run -d web-server \
  --web-port "$PORT" \
  --web-hostname 127.0.0.1 \
  --dart-define=API_URL=https://portfolio-api.oyinss.workers.dev
