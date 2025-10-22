#!/usr/bin/env bash
set -euo pipefail

# Optional: install faas-flow operator components (from upstream manifests)

kubectl apply -f https://raw.githubusercontent.com/s8sg/faas-flow/master/deploy/kubernetes.yaml

echo "faas-flow components applied (if available)."


