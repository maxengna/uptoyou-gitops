module "vpc" {
  source          = "../modules/vpc"
  security_groups = var.security_groups
  naming_prefix   = var.naming_prefix
}
