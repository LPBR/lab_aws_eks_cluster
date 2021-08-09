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
