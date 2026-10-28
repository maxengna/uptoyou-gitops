output "frontend_role_arn" {
  description = "ARN of the Frontend role"
  value       = aws_iam_role.frontend_role.arn
}
