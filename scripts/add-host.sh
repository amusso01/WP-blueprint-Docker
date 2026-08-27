#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "${ROOT}/scripts/_common.sh"

add_host() {
  local host="$1"
  if grep -Eq "[[:space:]]${host}([[:space:]]|$)" /etc/hosts; then
    echo "Already in /etc/hosts: ${host}"
    return 0
  fi
  echo "Adding ${host} to /etc/hosts (needs sudo)"
  echo "127.0.0.1 ${host}" | sudo tee -a /etc/hosts >/dev/null
}

add_host "${site_host}"
add_host "${mail_host}"
