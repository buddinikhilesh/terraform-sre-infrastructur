# modules/multi-tenant/main.tf
# Enforces multi-tenant isolation on Kubernetes
# Namespace isolation, resource quotas, network policies, RBAC

# Tenant namespace
resource "kubernetes_namespace" "tenant" {
  metadata {
    name = var.namespace
    labels = {
      tenant     = var.tenant_name
      managed-by = "terraform"
      isolation  = "enforced"
    }
  }
}

# Resource quota — limits total CPU and memory per tenant
resource "kubernetes_resource_quota" "tenant_quota" {
  metadata {
    name      = "${var.tenant_name}-quota"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }
  spec {
    hard = {
      "requests.cpu"    = var.cpu_request
      "limits.cpu"      = var.cpu_limit
      "requests.memory" = var.memory_request
      "limits.memory"   = var.memory_limit
      "pods"            = var.max_pods
    }
  }
}

# Default deny all network traffic between tenants
resource "kubernetes_network_policy" "default_deny" {
  count = var.enable_network_policy ? 1 : 0
  metadata {
    name      = "default-deny-all"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }
  spec {
    pod_selector {}
    policy_types = ["Ingress", "Egress"]
  }
}

# Allow traffic only within the same namespace
resource "kubernetes_network_policy" "allow_same_namespace" {
  count = var.enable_network_policy ? 1 : 0
  metadata {
    name      = "allow-same-namespace"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }
  spec {
    pod_selector {}
    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.namespace
          }
        }
      }
    }
    egress {
      to {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.namespace
          }
        }
      }
    }
    # Allow DNS resolution
    egress {
      ports {
        protocol = "UDP"
        port     = "53"
      }
    }
    policy_types = ["Ingress", "Egress"]
  }
}

# Tenant scoped RBAC role
resource "kubernetes_role" "tenant_role" {
  metadata {
    name      = "${var.tenant_name}-role"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }
  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "services", "configmaps"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["batch"]
    resources  = ["jobs"]
    verbs      = ["get", "list", "watch", "create", "delete"]
  }
}

# Bind RBAC role to service account
resource "kubernetes_role_binding" "tenant_binding" {
  metadata {
    name      = "${var.tenant_name}-binding"
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.tenant_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.service_account_name
    namespace = kubernetes_namespace.tenant.metadata[0].name
  }
}
