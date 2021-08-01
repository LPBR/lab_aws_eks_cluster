resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab_cluster.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_cluster.id
  }

  tags = {
    Nmae = "public"
  }
}

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
