#!/bin/sh
# Start script for the Your Spotify Railway template.
# Runs the database migrations, then the API server on an internal port and Caddy on $PORT.
set -e

PORT="${PORT:-8080}"
SERVER_PORT="${SERVER_PORT:-3001}"
export PORT SERVER_PORT

if [ -z "$CLIENT_ENDPOINT" ] && [ -n "$RAILWAY_PUBLIC_DOMAIN" ]; then
  CLIENT_ENDPOINT="https://$RAILWAY_PUBLIC_DOMAIN"
fi
if [ -z "$API_ENDPOINT" ] && [ -n "$CLIENT_ENDPOINT" ]; then
  API_ENDPOINT="${CLIENT_ENDPOINT%/}/api"
fi
export CLIENT_ENDPOINT API_ENDPOINT
export TIMEZONE="${TIMEZONE:-Etc/UTC}"

for v in CLIENT_ENDPOINT API_ENDPOINT SPOTIFY_PUBLIC SPOTIFY_SECRET MONGO_ENDPOINT; do
  eval "val=\${$v}"
  if [ -z "$val" ]; then
    echo "[railway-start] $v is not set" >&2
    exit 1
  fi
done

echo "[railway-start] web app: $CLIENT_ENDPOINT"
echo "[railway-start] API: $API_ENDPOINT"
echo "[railway-start] Spotify redirect URI to register: $API_ENDPOINT/oauth/spotify/callback"

# Write API_ENDPOINT and the CSP into the built web client (upstream script).
. /app/apps/client/scripts/run/variables.sh

cd /app/apps/server
sh /app/apps/server/scripts/run/deprecated.sh
node /app/apps/server/build/index.js --migrate

PORT="$SERVER_PORT" node /app/apps/server/build/index.js &
SERVER_PID=$!
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
CADDY_PID=$!

trap 'kill -TERM $SERVER_PID $CADDY_PID 2>/dev/null; wait; exit 0' TERM INT

while kill -0 "$SERVER_PID" 2>/dev/null && kill -0 "$CADDY_PID" 2>/dev/null; do
  sleep 5
done
echo "[railway-start] a process exited, stopping the container" >&2
kill -TERM "$SERVER_PID" "$CADDY_PID" 2>/dev/null || true
exit 1
