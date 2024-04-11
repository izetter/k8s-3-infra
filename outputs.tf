output "vpc_id" {
  value       = aws_vpc.eks_vpc.id
  description = "VPC id"
}

output "internet_gateway_id" {
  value = aws_internet_gateway.eks_igw.id
}