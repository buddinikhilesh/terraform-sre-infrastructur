variable "namespace" {
  description = "Kubernetes namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "environment" {
  description = "Environment name — production, staging, dev"
  type        = string
  default     = "production"
}

variable "grafana_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "pagerduty_key" {
  description = "PagerDuty integration key for alerting"
  type        = string
  sensitive   = true
}

variable "prometheus_retention" {
  description = "How long Prometheus keeps metrics data"
  type        = string
  default     = "30d"
}

variable "slo_target" {
  description = "SLO target percentage for burn rate alerts"
  type        = number
  default     = 99.9
}
