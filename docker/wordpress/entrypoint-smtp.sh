#!/bin/sh
set -eu

SMTP_HOST="${SMTP_HOST:-mailpit}"
SMTP_PORT="${SMTP_PORT:-1025}"
SMTP_USERNAME="${SMTP_USERNAME:-}"
SMTP_PASSWORD="${SMTP_PASSWORD:-}"
SMTP_AUTH="${SMTP_AUTH:-false}"
SMTP_FROM="${SMTP_FROM:-wordpress@localhost}"

auth="off"
case "${SMTP_AUTH}" in
  true|TRUE|on|ON|yes|YES|1) auth="on" ;;
esac

umask 022
cat > /etc/msmtprc <<EOF
defaults
tls off
tls_starttls off
tls_certcheck off
logfile -

account default
host ${SMTP_HOST}
port ${SMTP_PORT}
from ${SMTP_FROM}
auth ${auth}
EOF

if [ -n "${SMTP_USERNAME}" ]; then
  printf 'user %s\n' "${SMTP_USERNAME}" >> /etc/msmtprc
  printf 'password %s\n' "${SMTP_PASSWORD}" >> /etc/msmtprc
fi

exec docker-entrypoint.sh "$@"
