resource "aws_nat_gateway" "lab_cluster" {
  allocation_id = aws_eip.lab_cluster.id
  subnet_id     = aws_subnet.public_subnet[0].id
}
