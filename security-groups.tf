resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "worker_group_mgmt"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = ["10.0.0.0/8"]
  }
}

# EKS security groups created by eks module
# https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html
