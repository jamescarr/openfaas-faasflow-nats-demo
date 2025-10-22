# OpenFaaS + NATS (async) demo with node/Python functions

[Video walkthrough of this project](https://cdn.zappy.app/v3f46300bb23350178558a7ca541b2800.mp4)

This project demonstrates asynchronous, evented delivery on OpenFaaS using NATS. A node "main" function iterates a list of service names and invokes two other functions asynchronously via the OpenFaaS Gateway's async endpoint (backed by NATS queue-worker).

- main orchestrator (node): posts async jobs for each service to two functions
- uppercase (Python): prints the uppercased service name
- reverse (node): prints the reversed service name

## Prerequisites

- Docker
- kubectl
- Helm 3
- kind (Kubernetes-in-Docker)
- faas-cli

On macOS you can install with Homebrew:

```bash
brew install kind helm faas-cli
```

## 1) Create a kind cluster with a local registry

```bash
kubectl config use-context docker-desktop
./scripts/kind-create.sh
```

This creates a kind cluster named `openfaas` and a local registry at `localhost:5000` wired into the cluster.

## 2) Install OpenFaaS (includes NATS for async)

```bash
./scripts/install-openfaas.sh
./scripts/port-forward.sh
```

Grab the password for the gateway:

```bash
kubectl -n openfaas get secret basic-auth -o jsonpath='{.data.basic-auth-password}' | base64 --decode; echo
```

Login the CLI (in a separate terminal):

```bash
faas-cli login --gateway http://127.0.0.1:8080 -u admin --password-stdin
```

## 3) Build, push (to local registry), and deploy functions

Note due to the community license for openFaaS, only public images 
can be deployed, so the build and deploy step pushes to [ttl.sh](https://ttl.sh)
with a 1h expiration to satisfy this requirement.

```bash
./scripts/build-and-deploy.sh
```

This builds three images and pushes them to `localhost:5000`, then deploys them via `faas-cli` using `stack.yml`.

Once this completes, you should see output similar to the following:

```bash
Deployed. 202 Accepted.
URL: http://127.0.0.1:8080/function/reverse-node

Deploying: main-node.

Deployed. 202 Accepted.
URL: http://127.0.0.1:8080/function/main-node

Deploying: uppercase-python.

Deployed. 202 Accepted.
URL: http://127.0.0.1:8080/function/uppercase-python

Deployed. Functions:
Function                        Invocations     Replicas
main-node                 0               1
reverse-node              0               1
uppercase-python                0               1
```

## 4) Invoke the orchestrator and watch results

```bash
./scripts/invoke.sh
```

You should see the orchestrator respond quickly that async invocations were queued. Then check logs for the two worker functions to see output:

```bash
faas-cli logs uppercase-python
# in another terminal
faas-cli logs reverse-node
```

## What this demonstrates

- OpenFaaS async invocation via `POST /async-function/<fn>` using NATS queue-worker
- node and Python functions
- A node orchestrator that fans out events to two worker functions

## Notes on faas-flow

This demo focuses on OpenFaaS async with NATS. faas-flow is a workflow library for building more advanced flows on OpenFaaS. You can extend this demo by creating a flow function (typically written in Go using the faas-flow SDK) that composes `uppercase-python` and `reverse-node`. The async delivery still uses NATS under the hood.

## Cleanup

```bash
kind delete cluster --name openfaas || true
docker rm -f kind-registry || true
```
