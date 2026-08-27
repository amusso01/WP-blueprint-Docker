#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "${ROOT}/scripts/_common.sh"

if [[ ! -f "${ROOT}/.env" ]]; then
  echo "No .env file. Copy .env.example and set PROJECT_NAME:" >&2
  echo "  cp .env.example .env" >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not running. Open Docker Desktop and try again." >&2
  exit 1
fi

docker compose up -d "$@"

echo
echo "Site:  https://${site_host}"
echo "Mail:  https://${mail_host}"
echo
echo "(Same as: docker compose up -d)"
