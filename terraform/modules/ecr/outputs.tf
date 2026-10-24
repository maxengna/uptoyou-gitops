output "backend_ecr_policy_arn" {
  description = "The ARN of the ECR policy for the backend"
  value       = aws_iam_policy.backend_ecr_policy.arn
}

output "frontend_ecr_policy_arn" {
  description = "The ARN of the ECR policy for the frontend"
  value       = aws_iam_policy.frontend_ecr_policy.arn
}
