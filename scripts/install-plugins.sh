#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "${ROOT}/scripts/_common.sh"

plugins_file="${ROOT}/config/plugins.txt"

if [[ ! -f "${plugins_file}" ]]; then
  echo "Missing ${plugins_file}" >&2
  exit 1
fi

if ! ./scripts/wp core is-installed >/dev/null 2>&1; then
  echo "WordPress is not installed yet." >&2
  echo "Open https://${site_host}, finish the installer, then re-run this script." >&2
  exit 1
fi

while IFS= read -r line || [[ -n "${line}" ]]; do
  slug="${line%%#*}"
  slug="$(printf '%s' "${slug}" | tr -d '[:space:]')"
  [[ -z "${slug}" ]] && continue

  if ./scripts/wp plugin is-installed "${slug}"; then
    echo "Already installed: ${slug}"
    ./scripts/wp plugin activate "${slug}" >/dev/null
  else
    echo "Installing ${slug}..."
    ./scripts/wp plugin install "${slug}" --activate
  fi
done < "${plugins_file}"

echo "Default plugins are installed and active."
