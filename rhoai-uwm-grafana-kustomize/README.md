# RHOAI UWM Grafana - Kustomize Deployment

This repository contains Kustomize overlays for deploying Grafana for RHOAI User Workload Monitoring on OpenShift.

## Prerequisites

- OpenShift cluster with cluster-admin access
- `oc` CLI tool installed and configured
- Grafana Operator installed cluster-wide (not included in this deployment)

## Customize Namespace

**Before deploying, customize the namespace** if you don't want to use the default `user-grafana` namespace:

```bash
# Run the namespace change script with your desired namespace
./change-namespace.sh <your-namespace>

# Example: Change to namespace 'yakov'
./change-namespace.sh yakov
```

This script will automatically update all namespace references in:
- Infrastructure & RBAC configurations
- Grafana instance configurations
- Dashboard configurations
- README.md documentation

**Note:** The default namespace is `user-grafana`. If you want to use a different namespace, run the script before proceeding with deployment.

## Quick Start

Deploy in 3 phases to avoid race conditions:

```bash
# Phase 1: Infrastructure & RBAC
oc apply -k overlays/rhoai-uwm-user-grafana-app/infrastructure-rbac/
# Wait for CRDs: oc get crd | grep grafana.integreatly.org

# Phase 2: Grafana Instance & Core Resources
oc apply -k overlays/rhoai-uwm-user-grafana-app/grafana-instance/
# Wait for service account: oc get serviceaccount grafana-sa -n user-grafana

# Phase 3: Auth Secret & Dashboards
oc apply -k overlays/rhoai-uwm-user-grafana-app/dashboards/
# Wait for token: oc get secret grafana-auth-secret -n user-grafana
```

## What Gets Deployed

- **Infrastructure & RBAC**: Namespace, OperatorGroup, RBAC (ClusterRole, RoleBinding, ClusterRoleBinding)
- **Grafana Instance**: Grafana instance, datasource, folder, configmaps, secrets
- **Dashboards**: Authentication secret, 6 dashboards (vLLM, OVMS, GPU metrics)

## Access Grafana

```bash
oc get route grafana-route -n user-grafana
```

## Cleanup

```bash
oc delete -k overlays/rhoai-uwm-user-grafana-app/dashboards/
oc delete -k overlays/rhoai-uwm-user-grafana-app/grafana-instance/
oc delete -k overlays/rhoai-uwm-user-grafana-app/infrastructure-rbac/
```

## Why Phased Deployment?

The phased approach prevents race conditions:
- CRDs must exist before Grafana CRs (provided by cluster-wide Grafana Operator)
- Service account must exist before auth secret
- Wait steps ensure proper resource ordering

## Detailed Phase Information

### Infrastructure & RBAC

**What it deploys**:
- Namespace `user-grafana`
- OperatorGroup (tells cluster-wide Grafana operator to manage this namespace)
- RBAC (ClusterRole, RoleBinding, ClusterRoleBinding)

**Wait for CRDs** (from cluster-wide Grafana Operator):
```bash
oc get crd | grep grafana.integreatly.org
# Should see: grafanas, grafanadatasources, grafanadashboards, grafanafolders
```

### Grafana Instance

**What it deploys**:
- Grafana instance (CR)
- Grafana datasource
- Grafana folder
- ConfigMap and secrets

**Wait for service account**:
```bash
oc get serviceaccount grafana-sa -n user-grafana
```

### Dashboards

**What it deploys**:
- `grafana-auth-secret` (service account token)
- 6 dashboards: vllm, ovms, ovms-community, nvidia-gpu-vllm-metrics, amd-gpu-vllm-metrics, gaudi-gpu-vllm-metrics

**Wait for secret token**:
```bash
oc get secret grafana-auth-secret -n user-grafana -o jsonpath='{.data.token}' | base64 -d | wc -c
# Should be > 100 characters
```
