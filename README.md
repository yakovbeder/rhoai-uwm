# RHOAI Metrics Dashboard for Single Serving Models

Enable RHOAI User Workload Metrics for Single Serving Models.

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
└── rhoai-uwm-grafana-kustomize/ # Kustomize deployment (3-phase)
```

The deployment references the `common/base/` resources to eliminate duplication and ensure consistency.

## Dashboards

### vLLM Inference Metrics

The **vLLM** dashboard is the single source of truth for all vLLM model-serving metrics. It provides comprehensive monitoring with namespace and model auto-detection, including:
- Token throughput (generation and prompt)
- Request latency (E2E, TTFT, TPOT)
- Scheduler state (running, waiting, swapped)
- KV cache utilization
- Prefill and decode phase timing
- Preemption rate and prefix cache hit rate

### GPU Hardware Metrics

GPU-specific dashboards focus purely on hardware metrics (no model-serving metrics):

- **GPU Metrics - NVIDIA**: Temperature, SM clocks, power, utilization, VRAM, memory copy utilization, tensor core utilization (via DCGM)
- **GPU Metrics - AMD**: Temperature, clocks, power, utilization, VRAM usage (via ROCm SMI)
- **GPU Metrics - Intel Gaudi**: Temperature, SoC clocks, power, utilization, HBM usage (via Habanalabs)

### OpenVINO Model Server (OVMS)

- **OVMS**: Request time, inference execution time, success/failure rates, throughput, latency quantiles, queue wait time
- **OpenVINO Model Server - Model Metrics**: Per-model throughput, latency distribution, Apdex score, inference time, queue wait time, failure rate, error ratio

## Usage

Grab the Grafana route and open it in a browser:

```bash
NS="user-grafana"
GRAFANA_URL=$(oc get route -n $NS grafana-route -o jsonpath='{.spec.host}')
echo $GRAFANA_URL
```

## Screenshots

- **vLLM Dashboard** — Token throughput, E2E latency, scheduler state:

![vLLM Dashboard 1](./assets/dashboard1.png)

- **vLLM Dashboard** — Prompt/generation heatmaps, cache utilization, TPOT, TTFT:

![vLLM Dashboard 2](./assets/dashboard2.png)

- **OVMS Dashboard** — Request time, inference time, success/failure rates:

![OVMS Dashboard](./assets/dashboard3.png)

- **OpenVINO Model Server - Model Metrics** — Per-model throughput, latency, Apdex score:

![OVMS Community Dashboard](./assets/dashboard4.png)

- **GPU Metrics - NVIDIA** — Temperature, clocks, power, utilization:

![NVIDIA GPU Dashboard](./assets/dashboard5.png)
