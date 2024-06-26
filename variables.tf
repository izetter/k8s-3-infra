# Top level infrastructure ============================

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "13.0.0.0/16"
}

variable "cidr_public_1a" {
  description = "CIDR block for public subnet 1a"
  type        = string
  default     = "13.0.0.0/20"
}

variable "cidr_public_1b" {
  description = "CIDR block for public subnet 1b"
  type        = string
  default     = "13.0.16.0/20"
}

variable "cidr_private_1a" {
  description = "CIDR block for private subnet 1a"
  type        = string
  default     = "13.0.32.0/20"
}

variable "cidr_private_1b" {
  description = "CIDR block for private subnet 1a"
  type        = string
  default     = "13.0.48.0/20"
}



# EKS ================================================

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
  default     = "1.28"
}

# Note this: https://github.com/hashicorp/terraform/issues/14516
variable "eks_cluster_name" {
  description = "EKS Cluster name argument"
  type        = string
  default     = "eks"
}

variable "eks_node_group_name" {
  description = "EKS Node Group name argument"
  type        = string
  default     = "eks-node-group"
}

variable "instance_types" {
  description = "EC2 instance types for the EKS Node Group"
  type        = list(string)
  default     = ["t3.small"]
}