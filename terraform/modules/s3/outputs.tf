output "category_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.category.bucket
}

output "category_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.category.arn
}

output "product_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.product.bucket
}

output "product_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.product.arn
}
