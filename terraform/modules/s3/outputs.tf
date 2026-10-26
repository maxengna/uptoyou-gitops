output "uptoyoushop_bk_name" {
  description = "Map S3 bucket"
  value       = { for k, v in aws_s3_bucket.uptoyoushop-bk : k => v.bucket }
}

output "uptoyoushop_bk_arn" {
  description = "ARN of the S3 bucket"
  value       = { for k, v in aws_s3_bucket.uptoyoushop-bk : k => v.arn }
}

# output "app_s3_role_arn" {
#   description = "ARN of the S3 role"
#   value       = aws_iam_role.app_s3_role.arn
# }


output "app_s3_policy_arn" {
  description = "ARN of the S3 policy"
  value       = aws_iam_policy.app_s3_policy.arn
}
