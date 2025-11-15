# RHOAI UWM Grafana - GitOps Deployment

This repository contains Kustomize overlays for deploying Grafana for RHOAI User Workload Monitoring on OpenShift using ArgoCD.

## Prerequisites

- OpenShift cluster with cluster-admin access
- ArgoCD installed and configured
- Grafana Operator installed cluster-wide (not included in this deployment)
- `oc` CLI tool installed and configured

## Quick Start

### 1. Apply the ArgoCD Application

Apply the ArgoCD Application manifest to deploy all Grafana resources:

```bash
oc apply -f application.yaml
```

### 2. Verify Deployment

Check the ArgoCD application status:

```bash
oc get application.argoproj.io rhoai-uwm-grafana -n openshift-gitops
```

Wait for the application to sync (status should be "Synced" and health should be "Healthy").

### 3. Access Grafana

Get the Grafana route:

```bash
oc get route grafana-route -n user-grafana
```

## What Gets Deployed

- **Namespace**: `user-grafana`
- **OperatorGroup**: Allows cluster-wide Grafana operator to manage the namespace
- **Grafana Instance**: Grafana deployment with OAuth proxy
- **Grafana Datasource**: Prometheus datasource configured for User Workload Monitoring
- **Grafana Folder**: "RHOAI Single Model Serving Dashboards" folder
- **6 Dashboards**:
  - vLLM Dashboard
  - OVMS Dashboard
  - OpenVINO Model Server - Model Metrics - github
  - vLLM / GPU Metrics - NVIDIA
  - vLLM / GPU Metrics - AMD
  - vLLM / GPU Metrics - Intel Gaudi

## Configuration

The application is configured to:
- Automatically sync when changes are pushed to the repository
- Self-heal (automatically correct drift)
- Prune resources that are removed from the repository
- Create the namespace if it doesn't exist

## Repository Structure

```
rhoai-uwm-grafana-gitops/
├── application.yaml              # ArgoCD Application manifest
├── base/                         # Base Kustomize resources
│   └── instance/                 # Grafana instance configuration
└── overlays/
    └── rhoai-uwm-user-grafana-app/  # Main overlay with all resources
        ├── namespace.yaml
        ├── operator-group.yaml
        ├── grafana-folder.yaml
        └── *-dashboard.yaml      # Dashboard definitions
```

## Customization

To customize the deployment:

1. Modify the Kustomize overlays in `overlays/rhoai-uwm-user-grafana-app/`
2. Commit and push changes to your Git repository
3. ArgoCD will automatically sync the changes

## Troubleshooting

### Application Not Syncing

Check the ArgoCD application status and conditions:

```bash
oc get application.argoproj.io rhoai-uwm-grafana -n openshift-gitops -o yaml
```

### Dashboards Not Visible

Verify dashboards are deployed:

```bash
oc get grafanadashboard -n user-grafana
```

Check dashboard status:

```bash
oc get grafanadashboard <dashboard-name> -n user-grafana -o yaml
```

### Grafana Operator Not Found

Ensure the Grafana operator is installed cluster-wide. The OperatorGroup in this deployment tells the operator to manage the `user-grafana` namespace, but the operator itself must be installed separately.

## Cleanup

To remove all resources:

```bash
oc delete application.argoproj.io rhoai-uwm-grafana -n openshift-gitops
```

Note: This will remove the ArgoCD application, but resources may persist. To fully clean up:

```bash
oc delete namespace user-grafana
```
