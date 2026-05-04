# terraform-sre-infrastructure

Terraform modules for SRE infrastructure — observability stack,
multi-tenant isolation, and SLO alerting rules.
Built from real infrastructure patterns used at enterprise scale.

## What this solves
- Repeatable observability stack across all environments
- Multi-tenant Kubernetes isolation with zero-trust network policies
- SLO burn rate alerting rules deployed as code
- RBAC scoped per tenant — least privilege enforced
- Resource quotas preventing noisy neighbour problems

## Modules

| Module | What it provisions |
|---|---|
| `modules/observability` | Prometheus, Grafana, Alertmanager, SLO burn rate alerts |
| `modules/multi-tenant` | Namespace isolation, resource quotas, network policies, RBAC |

## Usage

```hcl
# Deploy observability stack
module "observability" {
  source           = "./modules/observability"
  namespace        = "monitoring"
  environment      = "production"
  grafana_password = var.grafana_password
  pagerduty_key    = var.pagerduty_key
  slo_target       = 99.9
}

# Create isolated tenant namespace
module "tenant" {
  source                = "./modules/multi-tenant"
  tenant_name           = "team-payments"
  namespace             = "payments-prod"
  cpu_limit             = "32"
  memory_limit          = "64Gi"
  enable_network_policy = true
}
```

## Prerequisites
- Terraform >= 1.5
- Kubernetes cluster running
- Helm >= 3.0
- kubectl configured

## Related resume projects
- Project PulseEngine — SRE observability platform at Southwest Airlines
- Project ChaosProof — multi-tenant Kubernetes isolation at Southwest Airlines
- ReliabilityCore — SLO/SLI framework rollout at Cognizant
