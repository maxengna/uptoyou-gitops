locals {
  common_tags = {
    Environment = "production"
    Project     = "uptoyoushop"
  }
}

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
