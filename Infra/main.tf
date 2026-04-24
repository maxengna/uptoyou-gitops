provider "aws" {
  region = var.region
}

# -------------------------
# VPC (ใช้ module สำเร็จรูป)
# -------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-vpc"

  cidr = "10.0.0.0/16"

  azs            = ["ap-southeast-1a", "ap-southeast-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  # public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  # single_nat_gateway = false

  map_public_ip_on_launch = true # Auto-assign public IP to EC2 instances in public subnets

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# -------------------------
# EKS Cluster
# -------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  # Node group (managed)
  eks_managed_node_groups = {
    public-nodes = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      # 🔥 สำคัญ: ให้ node มี public IP
      subnet_ids = module.vpc.public_subnets

      labels = {
        role = "public-node"
      }
    }
  }

  tags = {
    Environment = "dev"
  }
}
