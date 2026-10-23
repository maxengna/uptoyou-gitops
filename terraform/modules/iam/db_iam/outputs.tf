output "db_secrets_role_arn" {
  description = "ARN of the db Secrets role"
  value       = aws_iam_role.db_secrets_role.arn
}
