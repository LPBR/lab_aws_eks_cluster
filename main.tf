/**
  * # [LAB] AWS EKS cluster
  * A laboratory for EKS cluster.
  * Contains a publicly acessible grafana service, for monitoring data visualization.
  *
  * The Prometheus and Grafana deployment is based o kube-prometheus-stack helm chart.
  * https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
  *
  * In adition to the community monitoring itens and dasboards, this project contains a service
  * monitor called ping-exporter.
  * https://github.com/czerwonk/ping_exporter.
  *
  * The ping-exporter service monitor runs as a daemonset, sending ping requests to every node on the cluster,
  * collecting inter node connectivity data.
  *
  * ## Dependencies
  * - AWS CLI (https://github.com/aws/aws-cli)
  *   > Execute `$ aws configure ` (https://github.com/aws/aws-cli#configuration)
  * - Terraform (https://learn.hashicorp.com/tutorials/terraform/install-cli)
  * - kubectl (https://kubernetes.io/docs/tasks/tools/)
  *
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
  * ## Grafana
  * Provides several dashboards for visualizaing monitoring information.
  * 
  * To access it after running the `terraform apply`, get the Grafana Load Balancer URL with:
  * ```
  * terraform output grafana_url
  * ```
  * Paste it on your browser an use the following credentials to access it.
  * 
  *  > username: admin
  * 
  *  > password: admin123
  *
  * ## Clean up
  * To clean up created resources and avoid costs don't forget to run
  * ```
  * terraform destroy
  * ```
  * ## References and resources
  *
  * Documentation generated using terraform-docs
  * https://github.com/terraform-docs/terraform-docs
  * ```
  * terraform-docs markdown . | tee README.md
  * ```
  *
  * ### Creating a serviceMonitor for prometheus operator
  * https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/getting-started.md
  * https://stackoverflow.com/questions/52991038/how-to-create-a-servicemonitor-for-prometheus-operator
  *
  * ### Provisioning a EKS cluster
  * https://learn.hashicorp.com/tutorials/terraform/eks
  *
  * ### AWS EKS cluster with terraform - Examples
  * https://antonputra.com/category/aws-amazon-web-services/
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
