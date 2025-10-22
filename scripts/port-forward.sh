#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=openfaas

echo "Port-forwarding OpenFaaS gateway to 127.0.0.1:8080"
kubectl -n ${NAMESPACE} port-forward svc/gateway 8080:8080 >/dev/null 2>&1 &
sleep 2
echo "Gateway available at http://127.0.0.1:8080"


