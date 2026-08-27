#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "${ROOT}/scripts/_common.sh"

mkdir -p "${ROOT}/backups"
dump="${ROOT}/backups/wordpress.sql"

echo "Exporting ${MYSQL_DATABASE} to backups/wordpress.sql..."
docker compose exec -T -e MYSQL_PWD="${MYSQL_PASSWORD}" db \
  mysqldump --no-tablespaces -u "${MYSQL_USER}" "${MYSQL_DATABASE}" \
  > "${dump}"

echo "Wrote ${dump}"
echo "Commit this file if you want the database in Git (keep the repo private)."
