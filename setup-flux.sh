#!/usr/bin/env bash
set -euo pipefail
CTX="${CTX:-kind-kargo-quickstart}"
OWNER="${GITHUB_USER:-i-bharadwaj}"
REPO="${REPO:-flux-aegis-demo}"

kubectl config use-context "$CTX"
kubectl create namespace fake-aegis-qa --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace fake-aegis-prod --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f - <<YAML
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: flux-aegis-demo
  namespace: flux-system
spec:
  interval: 30s
  url: https://github.com/${OWNER}/${REPO}
  ref:
    branch: main
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: fake-aegis-qa
  namespace: flux-system
spec:
  interval: 30s
  path: ./apps/fake-aegis/overlays/qa
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-aegis-demo
  targetNamespace: fake-aegis-qa
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: fake-aegis-prod
  namespace: flux-system
spec:
  interval: 30s
  path: ./apps/fake-aegis/overlays/prod
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-aegis-demo
  targetNamespace: fake-aegis-prod
YAML

flux reconcile source git flux-aegis-demo --timeout=2m
flux reconcile kustomization fake-aegis-qa --timeout=2m
flux reconcile kustomization fake-aegis-prod --timeout=2m
flux get kustomizations
kubectl -n fake-aegis-qa get deploy,svc
kubectl -n fake-aegis-prod get deploy,svc
echo
echo "QA:   kubectl -n fake-aegis-qa port-forward svc/fake-aegis 8081:80"
echo "Prod: kubectl -n fake-aegis-prod port-forward svc/fake-aegis 8082:80"
