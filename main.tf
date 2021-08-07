/**
  * # [LAB] AWS EKS cluster
  * A laboratory for EKS cluster wiht nodes connection latency monitoring, using Prometheus and Grafana
  * ## Dependencies
  * - AWS CLI (https://github.com/aws/aws-cli)
  *   > Execute `$ aws configure ` (https://github.com/aws/aws-cli#configuration)
  * - Terraform (https://learn.hashicorp.com/tutorials/terraform/install-cli)
  * ## Usage
  * Install terraform dependencies
  * ```
  * terraform init
  * ```
  * Previews the execution plan and apply it
  * ```
  * terraform plan
  * ```
  * ```
  * terraform apply
  * ```
  * ### Aply kubeconfig
  * ```
  * aws eks update-kubeconfig --name eks_lab_cluster --region us-west-1
  * ```
  * ### Acessing Grafana
  * Acess grafana using port forward
  * ```
  * kubectl port-forward service/prometheus-community-grafana 3000:80 -n monitoring
  * ```
  * Access http://localhost:3000
  *  > username: admin
  * 
  * > password: admin123
  * ## Clean up
  * To clean up created resources and avoid costs don't forget to run
  * ```
  * terraform destroy
  * ```
  * ## Documentation
  * Documentation generated using terraform-docs
  * https://github.com/terraform-docs/terraform-docs
  * ```
  * terraform-docs markdown . | tee README.md
  * ```
  */

module "networking" {
  source       = "./networking"
  region       = var.region
  cluster_name = var.cluster_name
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "17.1.0"
  cluster_version = "1.21"
  cluster_name    = var.cluster_name
  subnets         = module.networking.subnets
  vpc_id          = module.networking.vpc_id

  # Allow private endpoints to connect to eks
  cluster_endpoint_private_access = true

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t2.small"
      asg_desired_capacity = 2
    },
  ]

  tags = {
    name = "lab_cluster"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

data "aws_instances" "cluster_nodes" {
  instance_tags = {
    name = "lab_cluster"
  }

  depends_on = [
    module.eks
  ]
}

resource "helm_release" "prometheus" {
  name       = "prometheus-community"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "17.1.1"

  create_namespace = true
  namespace        = "monitoring"

  values = [templatefile("prometheus-values.tmpl", {
    node_addrs = flatten(data.aws_instances.cluster_nodes.*.private_ips)
  })]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

resource "kubernetes_service_account" "ping_exporter" {
  metadata {
    name = "ping-exporter"
    namespace = "monitoring"
    labels = {
      name = "ping_exporter"
    }
  }

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

resource "kubernetes_cluster_role" "ping_exporter" {
  metadata {
    name = "ping-exporter"
    labels = {
      name = "ping_exporter"
    }
  }

  rule {
    api_groups = [""]
    resources = ["nodes"]
    verbs = ["list"]
  }
}

resource "kubernetes_cluster_role_binding" "ping_exporter" {
  metadata {
    name = "ping-exporter"
    labels = {
      name = "ping_exporter"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "ping-exporter"
  }

  subject {
    kind = "ServiceAccount"
    name = "ping-exporter"
    namespace = "monitoring"
  }
}

resource "kubernetes_daemonset" "ping_exporter" {
  metadata {
    name = "ping-exporter"
    namespace = "monitoring"
    labels = {
      name = "ping_exporter"
    }
  }

  spec {
    selector {
      match_labels = {
        name = "ping_exporter"
      }
    }

    template {
      metadata {
        labels = {
          name = "ping_exporter"
        }
      }

      spec {
        host_network         = true
        service_account_name = "ping-exporter"

        container {
          name  = "ping-exporter"
          image = "travelping/ping-exporter"

          port {
            container_port = 9427
          }

          env {
            name  = "PINGEXPORTER_VERSION"
            value = "1.0"
          }

          env {
            name  = "PINGEXPORTER_PING_INTERVAL"
            value = "5s"
          }

          env {
            name  = "PINGEXPORTER_PING_TIMEOUT"
            value = "4s"
          }

          env {
            name  = "PINGEXPORTER_PING_TARGET"
            value = "8.8.8.8"
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}
