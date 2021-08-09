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

# Montitoring
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
  }
}

# Deploy prometheus with kube-promethues-stack helm chart
resource "helm_release" "prometheus" {
  name       = "prometheus-community"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "17.1.1"

  create_namespace = true
  namespace        = var.monitoring_namespace

  # Configuration overwriting some defaul config values
  values = [templatefile("prometheus-values.tmpl", {
    node_addrs = flatten(data.aws_instances.cluster_nodes.*.private_ips)
  })]

  depends_on = [
    kubernetes_namespace.monitoring
  ]
}

# Deploy ping-exporter serviceMonitor
module "ping-exporter" {
  source               = "./ping-exporter"
  nodes_ips            = flatten(data.aws_instances.cluster_nodes.*.private_ips)
  monitoring_namespace = var.monitoring_namespace

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.prometheus,
  ]
}

# Publish Grafana to the internet with LoadBalancer
resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = var.monitoring_namespace
    labels = {
      name = "grafana"
    }
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "grafana"
    }
    port {
      name        = "web"
      port        = 80
      target_port = 3000
    }
    type = "LoadBalancer"
  }

  depends_on = [
    kubernetes_namespace.monitoring,
    helm_release.prometheus,
  ]
}
