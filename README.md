# RHOAI Metrics Dashboard for Single Serving Models

Enable RHOAI User Workload Metrics for Single Serving Models

## Prerequisites

- OpenShift 4.15 or later
- Red Hat OpenShift AI 2.22+ installed
- OpenShift AI KServe installed and configured
- GPU Operator installed and configured:
  - **NVIDIA GPUs**: NVIDIA GPU Operator
  - **AMD GPUs**: AMD GPU Operator (or equivalent)
  - **Intel Gaudi**: Intel Gaudi Operator (or equivalent)

## Installation

* [Configure Monitoring for the Single Model Serving Platform](https://docs.redhat.com/en/documentation/red_hat_openshift_ai_self-managed/3.0/html/managing_and_monitoring_models/managing_and_monitoring_models_on_the_single_model_serving_platform#configuring-monitoring-for-the-single-model-serving-platform_cluster-admin)
* [Configure GPU Monitoring Dashboard](https://docs.nvidia.com/datacenter/cloud-native/openshift/latest/enable-gpu-monitoring-dashboard.html)
* [Install the RHOAI Metrics Grafana and Dashboards for Single Serving Models with Kustomize](./rhoai-uwm-grafana-kustomize/README.md)

## Repository Structure

This repository uses Kustomize for deployment with shared base resources:

```
rhoai-uwm/
├── common/base/                 # Shared base resources
│   ├── rbac/                    # Phase 1: Namespace, RBAC
│   ├── core/                    # Phase 2: Grafana instance, datasource, folder
│   ├── auth/                    # Phase 3: Auth secret
│   └── dashboards/              # Phase 3: Dashboard definitions
└── rhoai-uwm-grafana-kustomize/ # Manual Kustomize deployment (3-phase)
```

The deployment references the `common/base/` resources to eliminate duplication and ensure consistency.

## Usage

Grab the Grafana route and open it in a browser:

```bash
NS="user-grafana"
GRAFANA_URL=$(oc get route -n $NS grafana-route -o jsonpath='{.spec.host}')
echo $GRAFANA_URL
```

- **vLLM Model Metrics Dashboard**: Provides Model metrics for vLLM Single Serving Models dashboard.

![vLLM Dashboard 1](./assets/dashboard1.png)

- **vLLM Service Performance Dashboard**: Provides Service Performance metrics for vLLM Single Serving Models dashboard.

![vLLM Dashboard 2](./assets/dashboard2.png)

- **OpenVINO Service Model Metrics Dashboard**: Provides metrics for OpenVINO Single Serving Models

![OpenVINO Dashboard 4](./assets/dashboard4.png)

- **OpenVINO Model Metrics Dashboard**: Provides Service Performance metrics for OpenVINO Single Serving Models.

![OpenVINO Dashboard 3](./assets/dashboard3.png)

- **GPU / vLLM Dashboard**: Provides GPU and vLLM performance metrics for Single Serving Models.

![GPU Dashboard 5](./assets/dashboard5.png)

![vLLM Dashboard 6](./assets/dashboard6.png)
