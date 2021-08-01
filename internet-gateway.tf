resource "aws_internet_gateway" "lab_cluster" {
  vpc_id = aws_vpc.lab_cluster.id

  tags = {
    Name = "lab-cluster-internet-gateway"
  }
}
