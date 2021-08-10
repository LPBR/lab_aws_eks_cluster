data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_instances" "cluster_nodes" {
  instance_tags = {
    name = "lab_cluster"
  }

  depends_on = [
    module.eks
  ]
}

data "dns_a_record_set" "grafana_dns" {
  host = kubernetes_service.grafana.status.0.load_balancer.0.ingress.0.hostname
  depends_on = [
    null_resource.wait_for_grafana_dns
  ]
}
