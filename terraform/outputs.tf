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

#output "ses_role_arn" {
#  value       = aws_iam_role.ses_role.arn
#  description = "IAM role ARN for SES IRSA"
#}

#output "ses_domain_identity" {
#  value       = aws_ses_domain_identity.mail_domain.arn
#  description = "SES domain identity ARN"
#}

#output "ses_dkim_tokens" {
#  value       = aws_ses_domain_dkim.mail_domain.dkim_tokens
#  description = "DKIM tokens for domain verification"
#}

#output "ses_service_account_role_arn" {
#  value       = aws_iam_role.ses_role.arn
#  description = "Role ARN to be used in Kubernetes ServiceAccount annotation"
#}
