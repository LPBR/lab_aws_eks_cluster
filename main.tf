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
  * $ terraform init
  * ```
  * Previews the execution plan and apply it
  * ```
  * $ terraform plan
  * $ terraform apply
  * ```
  * ## Clean up
  * To clean up created resources and avoid costs don't forget to run
  * ```
  * $ terraform destroy
  * ```
  * ## Documentation
  * Documentation generated using terraform-docs
  * https://github.com/terraform-docs/terraform-docs
  * ```
  * $ terraform-docs markdown . | tee README.md
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
}
