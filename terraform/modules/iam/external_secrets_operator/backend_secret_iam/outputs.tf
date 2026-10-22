output "backend_secrets_role_arn" {
  description = "ARN of the Backend Secrets role"
  value       = aws_iam_role.backend_secrets_role.arn
}
