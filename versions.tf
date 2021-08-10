terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "2.2.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.11.3"
    }

    grafana = {
      source = "grafana/grafana"
      version = "1.13.3"
    }
  }
}
