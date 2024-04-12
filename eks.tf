# EKS Roles and Policies ===============================================================


# Role that EKS will assume to create AWS resources for Kubernetes clusters.
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

# Permissions so K8S control plane can manage pertinent AWS resources via AWS API
resource "aws_iam_role_policy_attachment" "amazon_eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}


# EKS Cluster =========================================================================

resource "aws_eks_cluster" "eks" {
  name     = "eks-3"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version # Kubernetes version!

  vpc_config {

    # Subnets have to be in at least two different availability zones!
    subnet_ids = [
      aws_subnet.public_1a.id,
      aws_subnet.public_1b.id,
      aws_subnet.private_1a.id,
      aws_subnet.private_1b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.amazon_eks_cluster_policy]
}
