#!/usr/bin/env bash
set -euo pipefail

export OPENFAAS_URL=${OPENFAAS_URL:-http://127.0.0.1:8080}

# login using env var PASSWORD if provided
if [ -n "${PASSWORD:-}" ]; then
  echo -n "$PASSWORD" | faas-cli login --gateway ${OPENFAAS_URL} --username admin --password-stdin
fi

echo "Building and deploying via faas-cli"
# Pull templates (prefer node22, fallback to node)
faas-cli template store pull node22 || faas-cli template store pull node
faas-cli template store pull python3-http

# Use a public, anonymous registry (ttl.sh) for CE compatibility
RAND=$(hexdump -n 4 -v -e '/1 "%02x"' /dev/urandom)
TMP_STACK=$(mktemp)
sed -E "s|image: localhost:5000/([a-zA-Z0-9_-]+):latest|image: ttl\.sh/\\1-${RAND}:1h|g" stack.yml > "$TMP_STACK"

echo "Using generated stack with public images (ttl.sh), tag suffix: ${RAND}"

faas-cli build -f "$TMP_STACK"
faas-cli push -f "$TMP_STACK"
faas-cli deploy -f "$TMP_STACK" --gateway ${OPENFAAS_URL}

echo "Deployed. Functions:"
faas-cli list --gateway ${OPENFAAS_URL}


