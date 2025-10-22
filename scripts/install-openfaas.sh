#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=openfaas
FN_NAMESPACE=openfaas-fn

kubectl create namespace ${NAMESPACE} >/dev/null 2>&1 || true
kubectl create namespace ${FN_NAMESPACE} >/dev/null 2>&1 || true

helm repo add openfaas https://openfaas.github.io/faas-netes/
helm repo update

helm upgrade --install openfaas openfaas/openfaas \
  --namespace ${NAMESPACE} \
  --set functionNamespace=${FN_NAMESPACE} \
  --set generateBasicAuth=true \
  --set openfaasPRO=false

echo "Waiting for OpenFaaS to be ready..."
kubectl -n ${NAMESPACE} rollout status deploy/gateway --timeout=180s
kubectl -n ${NAMESPACE} rollout status deploy/queue-worker --timeout=180s

PASSWORD=$(kubectl -n ${NAMESPACE} get secret basic-auth -o jsonpath='{.data.basic-auth-password}' | base64 --decode)
echo "Gateway password: ${PASSWORD}"


