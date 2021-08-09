variable "cluster_name" {
  description = "Name of the cluster"
  default     = "lab_cluster"
}

variable "region" {
  description = "AWS region"
  default     = "us-west-1"
}

variable "monitoring_namespace" {
  description = "Namespace for monitoring resources"
  default     = "monitoring"
}
