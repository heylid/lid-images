#!/usr/bin/env bash
# Smoke test for the sandbox image. Usage: smoke-test.sh <image>
set -euo pipefail
image="${1:?usage: smoke-test.sh <image>}"
bundle=/etc/ssl/certs/ca-certificates.crt

run() { docker run --rm --network none "$image" "$@"; }

run bash -euc '
  test "$(id -un)" = lid && test "$(id -u)" = 1000
  ! getent passwd ubuntu
  sudo -n true
  git --version
  gh --version
  rg --version
  fd --version
  jq --version
  python3 --version
  python3 -m pip --version
  python3 -m venv --help >/dev/null
  node --version
  npm --version
  npx --version
  gcc --version
  test "$(pwd)" = /workspace
  touch /workspace/.probe && rm /workspace/.probe
'

for var in SSL_CERT_FILE REQUESTS_CA_BUNDLE NODE_EXTRA_CA_CERTS CURL_CA_BUNDLE GIT_SSL_CAINFO PIP_CERT; do
  got="$(run printenv "$var")"
  [ "$got" = "$bundle" ] || { echo "$var is '$got', want $bundle" >&2; exit 1; }
done
# sudo keeps the variables too.
got="$(run sudo -n printenv SSL_CERT_FILE)"
[ "$got" = "$bundle" ] || { echo "SSL_CERT_FILE under sudo is '$got'" >&2; exit 1; }
run test -s "$bundle"
echo "smoke test passed"
