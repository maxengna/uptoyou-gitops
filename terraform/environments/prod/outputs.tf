output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets_ids" {
  value = module.vpc.public_subnets_ids
}

output "security_groups_id" {
  value = module.vpc.security_groups_id
}
