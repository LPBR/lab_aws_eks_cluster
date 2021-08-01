module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_version = "1.21"
  cluster_name = var.cluster_name
  subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id

  # Allow private endpoints to connect to eks
  cluster_endpoint_private_access = true

  worker_groups = [
    {
      name = "worker-group-1"
      instance_type = "t2.small"
      asg_desired_capacity = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt.id]
    },
  ]
}
