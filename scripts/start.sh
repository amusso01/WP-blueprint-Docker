#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "${ROOT}/scripts/_common.sh"

if [[ ! -f "${ROOT}/.env" ]]; then
  echo "No .env file. Copy .env.example and set PROJECT_NAME / COMPOSE_PROJECT_NAME:" >&2
  echo "  cp .env.example .env" >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not running. Open Docker Desktop and try again." >&2
  exit 1
fi

if lsof -nP -iTCP:80 -sTCP:LISTEN >/dev/null 2>&1 && ! docker compose -f "${ROOT}/proxy/docker-compose.yml" ps --status running -q caddy >/dev/null 2>&1; then
  echo "Port 80 is already in use. If you still use Laravel Valet, run: valet stop" >&2
fi

echo "Starting shared proxy..."
docker compose -f "${ROOT}/proxy/docker-compose.yml" up -d

"${ROOT}/scripts/add-host.sh"

echo "Starting WordPress stack (${COMPOSE_PROJECT_NAME:-${PROJECT_NAME}})..."
docker compose up -d --build

echo "Waiting for WordPress..."
ready=0
for _ in $(seq 1 60); do
  if docker compose exec -T wordpress php -r 'echo "ok";' >/dev/null 2>&1; then
    ready=1
    break
  fi
  sleep 2
done

if [[ "${ready}" -ne 1 ]]; then
  echo "WordPress did not become ready. Check Docker Desktop logs for this project." >&2
  exit 1
fi

echo
echo "Site:     https://${site_host}"
echo "Mailpit:  https://${mail_host}"
echo "TablePlus: 127.0.0.1:${MYSQL_PORT:-3306}  user=${MYSQL_USER}  database=${MYSQL_DATABASE}"
echo

if ./scripts/wp core is-installed >/dev/null 2>&1; then
  ./scripts/install-plugins.sh
else
  echo "Finish the WordPress installer in the browser, then run:"
  echo "  ./scripts/install-plugins.sh"
fi

echo
echo "First time on this Mac: ./scripts/trust-caddy-ca.sh"
