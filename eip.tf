resource "aws_eip" "lab_cluster" {
  depends_on = [aws_internet_gateway.lab_cluster]
}
