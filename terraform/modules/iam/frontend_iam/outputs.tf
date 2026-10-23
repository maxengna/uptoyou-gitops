output "frontend_secrets_role_arn" {
  description = "ARN of the Frontend Secrets role"
  value       = aws_iam_role.frontend_secrets_role.arn
}
