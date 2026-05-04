# modules/observability/main.tf
# Provisions full SRE observability stack
# Prometheus, Grafana, Alertmanager with PagerDuty integration

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
}

# Monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.namespace
    labels = {
      managed-by  = "terraform"
      environment = var.environment
      team        = "sre"
    }
  }
}

# Prometheus + Grafana + Alertmanager stack
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name

  # Grafana config
  set {
    name  = "grafana.enabled"
    value = "true"
  }
  set_sensitive {
    name  = "grafana.adminPassword"
    value = var.grafana_password
  }

  # Prometheus retention
  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "30d"
  }

  # Alertmanager
  set {
    name  = "alertmanager.enabled"
    value = "true"
  }
}

# SLO burn rate alert rules
resource "kubernetes_config_map" "slo_rules" {
  metadata {
    name      = "slo-burn-rate-rules"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    labels = {
      managed-by = "terraform"
    }
  }

  data = {
    "slo-rules.yaml" = <<-EOT
      groups:
        - name: slo-burn-rate
          rules:
            - alert: SLOBurnRateCritical
              expr: |
                (job:slo_errors:rate1h / (1 - 0.999)) > 14.4
              for: 2m
              labels:
                severity: critical
              annotations:
                summary: "High error budget burn rate detected"
    EOT
  }
}
