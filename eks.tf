# EKS Cluster - Roles and Policies ========================================================

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
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}


# EKS Cluster ============================================================================

resource "aws_eks_cluster" "eks" {
  name     = var.eks_cluster_name
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

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}


# EKS Node Group - Roles and Policies ====================================================

resource "aws_iam_role" "eks_nodes_role" {
  name = "eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_role.name
}


# EKS Node Group  =========================================================================

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.eks_node_group_name
  node_role_arn   = aws_iam_role.eks_nodes_role.arn

  # Associated subnets must have the tag: kubernetes.io/cluster/CLUSTER_NAME 
  # Associating private subnets becasue those will hold the worker nodes,
  # while public subnets will hold the load balancers.
  subnet_ids = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1b.id
  ]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  ami_type       = "AL2_x86_64"
  capacity_type  = "ON_DEMAND"
  instance_types = var.instance_types

  # Disallow updating EKS Node Group AMI if the Kubernetes version is updated.
  force_update_version = false

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_container_registry_read_only_policy,
  ]
}
