terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

resource "aws_vpc" "cluster_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "LAB EKS Cluster"
  }
}

resource "aws_subnet" "subnet_a" {
  vpc_id = aws_vpc.cluster_vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "LAB subnet A"
  }
}

resource "aws_subnet" "subnet_b" {
  vpc_id = aws_vpc.cluster_vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "LAB subnet B"
  }
}
