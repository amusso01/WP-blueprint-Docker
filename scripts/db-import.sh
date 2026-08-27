#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "${ROOT}/scripts/_common.sh"

dump="${ROOT}/backups/wordpress.sql"

if [[ ! -f "${dump}" ]]; then
  echo "Missing ${dump}. Run ./scripts/db-export.sh first." >&2
  exit 1
fi

echo "Importing backups/wordpress.sql into ${MYSQL_DATABASE}..."
docker compose exec -T -e MYSQL_PWD="${MYSQL_PASSWORD}" db \
  mysql -u "${MYSQL_USER}" "${MYSQL_DATABASE}" \
  < "${dump}"

echo "Import finished."
