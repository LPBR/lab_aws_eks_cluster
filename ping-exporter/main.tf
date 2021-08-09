/**
  * # Ping-exporter prometheus serviceMonitor
  * ## About
  * Creates a prometheusService monitor, based on czerwonk/ping_exporter.
  * 
  * https://github.com/czerwonk/ping_exporter.
  *
  * Creates the deamon set, it's configuration file, service_account, service and serviceMonitor.
  * 
  * https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/getting-started.md#include-servicemonitors
  */

resource "kubernetes_service_account" "ping-exporter" {
  metadata {
    name      = "ping-exporter"
    namespace = var.monitoring_namespace
    labels = {
      name = "ping-exporter"
    }
  }
}

resource "kubernetes_cluster_role" "ping-exporter" {
  metadata {
    name = "ping-exporter"
    labels = {
      name = "ping-exporter"
    }
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["list"]
  }
}

resource "kubernetes_cluster_role_binding" "ping-exporter" {
  metadata {
    name = "ping-exporter"
    labels = {
      name = "ping-exporter"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "ping-exporter"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "ping-exporter"
    namespace = var.monitoring_namespace
  }
}

# Ping exporter config map
resource "kubernetes_config_map" "ping-exporter" {
  metadata {
    name      = "ping-exporter"
    namespace = var.monitoring_namespace
  }

  data = {
    "config.yml" = <<EOF
${yamlencode({
targets: flatten(var.nodes_ips)
})}

dns:
  refresh: 2m15s
  nameserver: 1.1.1.1

ping:
  internaval: 2s
  timeout: 3s
  history-size: 42
  payload-size: 120
EOF
  }
}

# Ping exporter daemonset
resource "kubernetes_daemonset" "ping-exporter" {
  metadata {
    name      = "ping-exporter"
    namespace = var.monitoring_namespace
    labels = {
      name       = "ping-exporter"
      prometheus = "monitoring"
    }
  }

  spec {
    selector {
      match_labels = {
        name = "ping-exporter"
      }
    }

    template {
      metadata {
        labels = {
          name = "ping-exporter"
        }
      }

      spec {
        host_network         = true
        service_account_name = "ping-exporter"

        container {
          name  = "ping-exporter"
          image = "czerwonk/ping_exporter"

          port {
            container_port = 9427
          }

          volume_mount {
            name       = "config"
            mount_path = "/config"
          }
        }

        volume {
          name = "config"
          config_map {
            name = "ping-exporter"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "ping-exporter" {
  metadata {
    name = "ping-exporter"
    namespace = var.monitoring_namespace
    labels = {
      name = "ping-exporter"
      prometheus = "monitoring"
    }
  }

  spec {
    selector = {
        name = "ping-exporter"
    }
    port {
      name = "metrics"
      port = 9427
      target_port = 9427
    }
    type = "ClusterIP"
  }
}

resource "kubectl_manifest" "ping-exporter" {
  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: ping-exporter
  namespace: ${var.monitoring_namespace}
  labels:
    name: ping-exporter
    prometheus: monitoring
spec:
  selector:
    matchLabels:
      name: ping-exporter
  endpoints:
    - port: metrics
  YAML
}
