# Demo for Mark — Aegis (Argo) vs same shape on Flux

## Mapping

**Aegis today:** GHA build → QA infra PR auto-merge + Argo autosync → prod infra PR human merge + Argo apply.

**This POC:** HTML version string = infra tag bump. QA push to main auto-applies via Flux. Prod waits for PR merge. No Argo Sync UI.

## Live demo

```bash
kubectl config use-context kind-kargo-quickstart
kubectl -n fake-aegis-qa port-forward svc/fake-aegis 8081:80    # http://localhost:8081
kubectl -n fake-aegis-prod port-forward svc/fake-aegis 8082:80  # http://localhost:8082
```

1) QA: edit `apps/fake-aegis/overlays/qa/index.html` → v1.1.0, commit+push main, reconcile, refresh 8081.
2) Prod: branch+PR for prod bump; 8082 unchanged until merge; then reconcile; refresh 8082.
3) Argo UI: http://localhost:31080 — Sync still exists (contrast).

```bash
flux reconcile source git flux-aegis-demo
flux reconcile kustomization fake-aegis-qa
flux reconcile kustomization fake-aegis-prod
```
