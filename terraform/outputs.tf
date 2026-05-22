output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}


output "vpc_id" {
  value = module.vpc.vpc_id
}

output "alb_role_arn" {
  value = aws_iam_role.lb_controller_role.arn
}
