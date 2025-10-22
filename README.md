# OpenFaaS + NATS (async) demo with TypeScript/Python functions

<video src="https://cdn.zappy.app/v3732a2bd3e2611eb62169cc315bf3041.mp4" controls width="600">
  Your browser does not support the video tag.
</video>

This project demonstrates asynchronous, evented delivery on OpenFaaS using NATS. A TypeScript "main" function iterates a list of service names and invokes two other functions asynchronously via the OpenFaaS Gateway's async endpoint (backed by NATS queue-worker).

- main orchestrator (TypeScript): posts async jobs for each service to two functions
- uppercase (Python): prints the uppercased service name
- reverse (TypeScript): prints the reversed service name

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
cd openfaas-faasflow-nats-demo
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
URL: http://127.0.0.1:8080/function/reverse-typescript

Deploying: main-typescript.

Deployed. 202 Accepted.
URL: http://127.0.0.1:8080/function/main-typescript

Deploying: uppercase-python.

Deployed. 202 Accepted.
URL: http://127.0.0.1:8080/function/uppercase-python

Deployed. Functions:
Function                        Invocations     Replicas
main-typescript                 0               1
reverse-typescript              0               1
uppercase-python                0               1
```

## 4) Invoke the orchestrator and watch results

```bash
./scripts/invoke.sh
```

You should see the orchestrator respond quickly that async invocations were queued. Then check logs for the two worker functions to see output:

```bash
faas-cli logs uppercase-python --follow
# in another terminal
faas-cli logs reverse-typescript --follow
```

## What this demonstrates

- OpenFaaS async invocation via `POST /async-function/<fn>` using NATS queue-worker
- TypeScript and Python functions
- A TypeScript orchestrator that fans out events to two worker functions

## Notes on faas-flow

This demo focuses on OpenFaaS async with NATS. faas-flow is a workflow library for building more advanced flows on OpenFaaS. You can extend this demo by creating a flow function (typically written in Go using the faas-flow SDK) that composes `uppercase-python` and `reverse-typescript`. The async delivery still uses NATS under the hood.

## Cleanup

```bash
kind delete cluster --name openfaas || true
docker rm -f kind-registry || true
```
