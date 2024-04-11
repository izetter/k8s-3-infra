# Top level infrastructure (VPC, Subnets, Security Groups, etc)

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
