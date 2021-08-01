resource "aws_subnet" "private_subnet" {
  count             = length(data.aws_availability_zones.available.names)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.lab_cluster.id
  tags = {
    Name                                        = "lab-private-subnet-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # Allow Kubernetes to use private subnets for internal load balancers
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "public_subnet" {
  count                   = length(data.aws_availability_zones.available.names)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "10.0.10${count.index}.0/24"
  vpc_id                  = aws_vpc.lab_cluster.id
  map_public_ip_on_launch = true
  tags = {
    Name                                        = "lab-public-subnet-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # Allow Kubernetes to use public subnets for external load balancers
    "kubernetes.io/role/elb" = "1"
  }
}
