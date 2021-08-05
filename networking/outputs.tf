output "vpc_id" {
  description = "VPC id"
  value = aws_vpc.lab_cluster.id
}

output "subnets" {
  description = "Private subnet for eks cluster"
  value = aws_subnet.private_subnet[*].id
}
