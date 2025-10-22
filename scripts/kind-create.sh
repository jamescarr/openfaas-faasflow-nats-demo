#!/usr/bin/env bash
set -euo pipefail

# Create a local Docker registry and KinD cluster wired to it

REG_NAME="kind-registry"
REG_PORT="5000"
CLUSTER_NAME="openfaas"

running="$(docker inspect -f '{{.State.Running}}' ${REG_NAME} 2>/dev/null || true)"
if [ "${running}" != "true" ]; then
  echo "Creating local registry ${REG_NAME} on localhost:${REG_PORT}"
  docker run -d --restart=always -p "127.0.0.1:${REG_PORT}:5000" --name "${REG_NAME}" registry:2
fi

cat <<EOF | kind create cluster --name "${CLUSTER_NAME}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
- |-
  [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${REG_PORT}"]
      endpoint = ["http://${REG_NAME}:5000"]
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 30080
    hostPort: 8080
    protocol: TCP
EOF

# Connect the registry to the cluster network
docker network connect "kind" "${REG_NAME}" >/dev/null 2>&1 || true

# Document the local registry within the cluster
kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${REG_PORT}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

echo "KinD cluster '${CLUSTER_NAME}' is ready with local registry at localhost:${REG_PORT}"


