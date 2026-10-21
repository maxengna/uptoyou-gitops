output "uptoyoushop_bk_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.uptoyoushop-bk.bucket
}

output "uptoyoushop_bk_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.uptoyoushop-bk.arn
}

output "app_s3_role_arn" {
  description = "ARN of the S3 role"
  value       = aws_iam_role.app_s3_role.arn
}
