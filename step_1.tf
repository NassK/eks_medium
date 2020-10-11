provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

## Step 1: Configuring the VPC that will host the EKS cluster
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-eks-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  vpc_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
  
  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
  
  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  enable_dns_hostnames = true # Needed for worker nodes in private subnets
  enable_dns_support = true

  /**
   * Needed for workers node in public subnets. 
   * map_public_ip_on_launch = true
   */
}