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
- Overlay configurations
- README.md documentation

**Note:** The default namespace is `user-grafana`. If you want to use a different namespace, run the script before proceeding with deployment.

**Note:** The script is cross-platform compatible (works on both macOS and Linux).

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

- **Phase 1 - Infrastructure & RBAC** (5 resources):
  - Namespace `user-grafana`
  - ClusterRole `grafana-proxy`
  - ClusterRoleBinding `cluster-monitoring-view-user-grafana`
  - ClusterRoleBinding `auth-delegator-user-grafana`
  - RoleBinding `grafana-proxy`

- **Phase 2 - Grafana Instance** (5 resources):
  - ConfigMap `ocp-injected-certs`
  - Secret `grafana-proxy` (session secret)
  - Grafana `grafana`
  - GrafanaDatasource `prometheus-grafanadatasource`
  - GrafanaFolder `rhoai-single-model-serving-dashboards`

- **Phase 3 - Dashboards** (7 resources):
  - Secret `grafana-auth-secret`
  - 6 GrafanaDashboards (vLLM, OVMS, GPU metrics)

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

## Repository Structure

```
rhoai-uwm-grafana-kustomize/
├── change-namespace.sh           # Cross-platform namespace customization script
└── overlays/
    └── rhoai-uwm-user-grafana-app/
        ├── infrastructure-rbac/  # Phase 1: references common/base/rbac
        ├── grafana-instance/     # Phase 2: references common/base/core
        └── dashboards/           # Phase 3: references common/base/auth + dashboards

common/base/                      # Shared base resources
├── rbac/                         # Namespace, RBAC resources
├── core/                         # Grafana instance, datasource, folder
├── auth/                         # Auth secret
└── dashboards/                   # Dashboard definitions
```

**Note:** Base resources are defined in `common/base/` to eliminate duplication and improve maintainability.
