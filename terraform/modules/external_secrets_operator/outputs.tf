output "external_secrets_policy_arn" {
  description = "ARN of the external secrets operator policy"
  value       = aws_iam_policy.external_secrets_policy.arn
}
