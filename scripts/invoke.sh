#!/usr/bin/env bash
set -euo pipefail

export OPENFAAS_URL=${OPENFAAS_URL:-http://127.0.0.1:8080}

echo "Invoking orchestrator (main-node)"
echo "" | faas-cli invoke main-node --gateway ${OPENFAAS_URL}

echo "Check logs with:"
echo "  faas-cli logs uppercase-python"
echo "  faas-cli logs reverse-node"


