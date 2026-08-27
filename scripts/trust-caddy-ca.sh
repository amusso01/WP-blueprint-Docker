#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck disable=SC1091
source "${ROOT}/scripts/_common.sh"

proxy_compose=(docker compose -f "${ROOT}/proxy/docker-compose.yml")

if ! docker info >/dev/null 2>&1; then
  echo "Docker is not running. Open Docker Desktop and try again." >&2
  exit 1
fi

echo "Starting shared HTTPS proxy (wp-proxy)..."
"${proxy_compose[@]}" up -d

cert_path="/data/caddy/pki/authorities/local/root.crt"
tmp_cert="$(mktemp /tmp/caddy-local-root.XXXXXX.crt)"
cleanup() { rm -f "${tmp_cert}"; }
trap cleanup EXIT

echo "Waiting for Caddy's local CA..."
found=0
for _ in $(seq 1 30); do
  if "${proxy_compose[@]}" exec -T caddy test -f "${cert_path}" 2>/dev/null; then
    "${proxy_compose[@]}" exec -T caddy cat "${cert_path}" > "${tmp_cert}"
    if [[ -s "${tmp_cert}" ]]; then
      found=1
      break
    fi
  fi
  sleep 2
done

if [[ "${found}" -ne 1 ]]; then
  echo "Could not find Caddy CA at ${cert_path}." >&2
  echo "Start a site once (./scripts/start.sh) so Caddy issues internal certs, then re-run this script." >&2
  exit 1
fi

echo "Trusting Caddy local CA in the macOS System keychain (needs sudo)..."
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "${tmp_cert}"

echo "Done. Restart the browser if https://${site_host} still warns about the certificate."
echo "Firefox uses its own store; import the CA there if needed."
