locals {
  common_tags = {
    Environment = "production"
    Project     = "uptoyoushop"
  }
}

################################################################################
# Create VPC and components
################################################################################
module "vpc" {
  source              = "../../modules/vpc"
  vpc_cidr            = var.vpc.cidr
  naming_prefix       = var.naming_prefix
  security_groups     = var.security_groups
  common_tags         = local.common_tags
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  public_rt_cidr      = var.public_rt_cidr
  azs                 = var.azs

}

################################################################################
# Create EKS Cluster and Node Groups
################################################################################
module "eks" {
  source             = "../../modules/eks"
  public_subnets_id  = module.vpc.public_subnets_ids
  security_groups_id = module.vpc.security_groups_id
  common_tags        = local.common_tags
  cluster_config     = var.cluster_config
  naming_prefix      = var.naming_prefix
  node_groups        = var.node_groups
  addons             = var.addons
}

################################################################################
# Create S3 Bucket
################################################################################
module "s3" {
  source        = "../../modules/s3"
  common_tags   = local.common_tags
  s3_bucket     = var.s3_bucket
  naming_prefix = var.naming_prefix
}
