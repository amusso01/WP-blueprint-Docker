#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "${ROOT}/scripts/_common.sh"

cd "${ROOT}"

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not running. Open Docker Desktop and try again." >&2
  exit 1
fi

if ! docker compose ps --status running -q caddy >/dev/null 2>&1; then
  echo "Caddy is not running. Start the stack first:" >&2
  echo "  docker compose up -d" >&2
  exit 1
fi

cert_path="/data/caddy/pki/authorities/local/root.crt"
tmp_cert="$(mktemp /tmp/caddy-local-root.XXXXXX.crt)"
cleanup() { rm -f "${tmp_cert}"; }
trap cleanup EXIT

echo "Waiting for Caddy's local CA..."
found=0
for _ in $(seq 1 30); do
  if docker compose exec -T caddy test -f "${cert_path}" 2>/dev/null; then
    docker compose exec -T caddy cat "${cert_path}" > "${tmp_cert}"
    if [[ -s "${tmp_cert}" ]]; then
      found=1
      break
    fi
  fi
  sleep 2
done

if [[ "${found}" -ne 1 ]]; then
  echo "Could not find Caddy CA at ${cert_path}." >&2
  echo "Visit https://${site_host} once, then re-run this script." >&2
  exit 1
fi

echo "Trusting Caddy local CA in the macOS System keychain (needs sudo)..."
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "${tmp_cert}"

echo "Done. Restart the browser if https://${site_host} still warns about the certificate."
echo "Firefox uses its own store; import the CA there if needed."
