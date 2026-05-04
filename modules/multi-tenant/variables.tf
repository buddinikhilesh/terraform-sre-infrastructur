variable "tenant_name" {
  description = "Name of the tenant — used for labeling and naming resources"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the tenant"
  type        = string
}

variable "cpu_request" {
  description = "Total CPU requests allowed for tenant namespace"
  type        = string
  default     = "16"
}

variable "cpu_limit" {
  description = "Total CPU limits allowed for tenant namespace"
  type        = string
  default     = "32"
}

variable "memory_request" {
  description = "Total memory requests allowed for tenant namespace"
  type        = string
  default     = "32Gi"
}

variable "memory_limit" {
  description = "Total memory limits allowed for tenant namespace"
  type        = string
  default     = "64Gi"
}

variable "max_pods" {
  description = "Maximum number of pods in tenant namespace"
  type        = number
  default     = 50
}

variable "enable_network_policy" {
  description = "Enable network policy for zero-trust isolation between tenants"
  type        = bool
  default     = true
}

variable "service_account_name" {
  description = "Service account to bind tenant RBAC role to"
  type        = string
  default     = "default"
}
