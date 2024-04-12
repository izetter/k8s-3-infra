# VPC, IGW ================================================================

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "EKSVPC-3"
  }
}

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}


# Subnets ================================================================

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "13.0.0.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name                           = "eks-subnet-public-1a"
    "kubernetes.io/cluster/my-eks" = "shared"
    "kubernetes.io/role/elb"       = 1
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "13.0.16.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name                           = "eks-subnet-public-1b"
    "kubernetes.io/cluster/my-eks" = "shared"
    "kubernetes.io/role/elb"       = 1
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "13.0.32.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name                              = "eks-subnet-private-1a"
    "kubernetes.io/cluster/my-eks"    = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "13.0.48.0/20"
  availability_zone = "us-east-1b"
  tags = {
    Name                              = "eks-subnet-private-1b"
    "kubernetes.io/cluster/my-eks"    = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}


# EIP ================================================================

resource "aws_eip" "nat1a" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.eks_igw]
  tags = {
    Name = "eks-eip-NAT-1a"
  }
}

resource "aws_eip" "nat1b" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.eks_igw]
  tags = {
    Name = "eks-eip-NAT-1b"
  }
}


# NAT Gateways ================================================================

resource "aws_nat_gateway" "nat_gw1a" {
  allocation_id = aws_eip.nat1a.id
  subnet_id     = aws_subnet.public_1a.id
  tags = {
    Name = "eks-NAT-GW-1a"
  }
}

resource "aws_nat_gateway" "nat_gw1b" {
  allocation_id = aws_eip.nat1b.id
  subnet_id     = aws_subnet.public_1b.id
  tags = {
    Name = "eks-NAT-GW-1b"
  }
}
