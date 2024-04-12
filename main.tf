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

# String interpolation in attribute property names seems to not be supported,
# they must be constant. So tags for kubernetes remain hard-coded for now,
# but later test if it works https://github.com/hashicorp/terraform/issues/14516
# Also later test that `kubernetes.io/cluster/eks` may not be neccessary anymore:
# https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "13.0.0.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name                        = "eks-subnet-public-1a"
    "kubernetes.io/cluster/eks" = "shared" # Allow EKS to discover and use this subnet
    "kubernetes.io/role/elb"    = 1        # Indicates EKS that subnet is public and can be used with public LB
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "13.0.16.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name                        = "eks-subnet-public-1b"
    "kubernetes.io/cluster/eks" = "shared"
    "kubernetes.io/role/elb"    = 1
  }
}

resource "aws_subnet" "private_1a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "13.0.32.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name                              = "eks-subnet-private-1a"
    "kubernetes.io/cluster/eks"       = "shared"
    "kubernetes.io/role/internal-elb" = 1     # Indicates EKS that subnet is private and can be used with private LB
  }
}

resource "aws_subnet" "private_1b" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "13.0.48.0/20"
  availability_zone = "us-east-1b"
  tags = {
    Name                              = "eks-subnet-private-1b"
    "kubernetes.io/cluster/eks"       = "shared"
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


# Route Tables ================================================================

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "eks-PublicRT"
  }
}

resource "aws_route_table" "private_rt_1a" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw1a.id
  }

  tags = {
    Name = "eks-PrivateRT-1a"
  }
}

resource "aws_route_table" "private_rt_1b" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw1b.id
  }

  tags = {
    Name = "eks-PrivateRT-1b"
  }
}


# Route Table Associations ================================================================

resource "aws_route_table_association" "public1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private1a" {
  subnet_id      = aws_subnet.private_1a.id
  route_table_id = aws_route_table.private_rt_1a.id
}

resource "aws_route_table_association" "private1b" {
  subnet_id      = aws_subnet.private_1b.id
  route_table_id = aws_route_table.private_rt_1b.id
}
