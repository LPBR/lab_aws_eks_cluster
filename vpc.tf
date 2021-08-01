resource "aws_vpc" "lab_cluster" {
  cidr_block = "10.0.0.0/16"

  # EKS VPC requirements
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lab-cluster-vpc"
  }
}
