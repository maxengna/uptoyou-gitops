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
  source             = "../../modules/vpc"
  vpc_cidr           = var.vpc_cidr
  naming_prefix      = var.naming_prefix
  security_groups    = var.security_groups
  common_tags        = local.common_tags
  public_subnet_cidr = var.public_subnet_cidr
  # private_subnet_cidr = var.private_subnet_cidr
  public_rt_cidr = var.public_rt_cidr
  azs            = var.azs

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
  standard_addons    = var.standard_addons
  ebs_csi            = var.ebs_csi
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


################################################################################
# CREATE S3 POLICY
################################################################################
module "s3_policy" {
  source        = "../../modules/s3_policy"
  naming_prefix = var.naming_prefix
}


################################################################################
# CREATE EXTERNAL SECRETS POLICY
################################################################################
module "external_secrets_policy" {
  source        = "../../modules/external_secrets_policy"
  naming_prefix = var.naming_prefix
}

################################################################################
# CREATE ECR POLICY
################################################################################
module "ecr" {
  source        = "../../modules/ecr"
  naming_prefix = var.naming_prefix
}

################################################################################
# CREATE DB IAM
################################################################################
module "db_iam" {
  source            = "../../modules/iam/db_iam"
  naming_prefix     = var.naming_prefix
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  common_tags       = local.common_tags
}

################################################################################
# CREATE BACKEND IAM
################################################################################
module "backend_iam" {
  source                      = "../../modules/iam/backend_iam"
  naming_prefix               = var.naming_prefix
  oidc_provider_arn           = module.eks.oidc_provider_arn
  oidc_provider_url           = module.eks.oidc_provider_url
  external_secrets_policy_arn = module.external_secrets_policy_arn
  app_s3_policy_arn           = module.s3.app_s3_policy_arn
  backend_ecr_policy_arn      = module.ecr.backend_ecr_policy_arn
  common_tags                 = local.common_tags
}

################################################################################
# CREATE FRONTEND IAM
################################################################################
module "frontend_iam" {
  source                      = "../../modules/iam/frontend_iam"
  naming_prefix               = var.naming_prefix
  oidc_provider_arn           = module.eks.oidc_provider_arn
  oidc_provider_url           = module.eks.oidc_provider_url
  external_secrets_policy_arn = module.external_secrets_policy_arn
  frontend_ecr_policy_arn     = module.ecr.frontend_ecr_policy_arn
  common_tags                 = local.common_tags
}
