output "vpc_id" {
  value       = aws_vpc.eks_vpc.id
  description = "VPC id"
}

output "internet_gateway_id" {
  value = aws_internet_gateway.eks_igw.id
}

output "node_group_id" {
  value = aws_eks_node_group.node_group.id
}

output "aws_eks_cluster_id" {
  value = aws_eks_cluster.eks.id
}