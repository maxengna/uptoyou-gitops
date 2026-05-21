output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}


output "vpc_id" {
  value = aws_vpc.main.id
}

output "alb_role_arn" {
  value = aws_iam_role.alb.arn
}
