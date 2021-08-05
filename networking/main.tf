# Cluster VPC
resource "aws_vpc" "lab_cluster" {
  cidr_block = "10.0.0.0/16"

  # EKS VPC requirements
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "lab-cluster-vpc"
  }
}

# Public subnets
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

# Private subnets for worker nodes
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

# Internet gateway to allow internet access to public subnet
resource "aws_internet_gateway" "lab_cluster" {
  vpc_id = aws_vpc.lab_cluster.id

  tags = {
    Name = "lab-cluster-internet-gateway"
  }
}

# Public IP address
resource "aws_eip" "lab_cluster" {
  depends_on = [aws_internet_gateway.lab_cluster]
}

# Single NAT gateway used by private subnets to reach the internet
resource "aws_nat_gateway" "lab_cluster" {
  allocation_id = aws_eip.lab_cluster.id
  subnet_id     = aws_subnet.public_subnet[0].id
}

# Private subnet route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab_cluster.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.lab_cluster.id
  }

  tags = {
    Name = "private"
  }
}

# Public subnet route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab_cluster.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_cluster.id
  }

  tags = {
    Name = "public"
  }
}

# Associate public subnet table with the public subnet
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

# Associate private subnet table with the private subnet
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private.id
}
