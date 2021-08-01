module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  # EKS network requirements
  # https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html

  azs = data.aws_availability_zones.available.names
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  # Subnet tags for eks cluster AWS
  # https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # Allow Kubernetes to use public subnets for external load balancers
    "kubernetes.io/role/elb" = "1"
  }

  # 
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # Allow Kubernetes to use private subnets for internal load balancers
    "kubernetes.io/role/internal-elb" = "1"
  }
}
