#!/usr/bin/env bash
# Shared helpers. Sourced by other scripts in this directory.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ -f "${ROOT}/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${ROOT}/.env"
  set +a
fi

PROJECT_NAME="${PROJECT_NAME:-my-project}"
MYSQL_DATABASE="${MYSQL_DATABASE:-wordpress}"
MYSQL_USER="${MYSQL_USER:-wordpress}"
MYSQL_PASSWORD="${MYSQL_PASSWORD:-wordpress}"
MYSQL_ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD:-root}"

site_host="local.${PROJECT_NAME}.dev"
mail_host="mail.local.${PROJECT_NAME}.dev"
