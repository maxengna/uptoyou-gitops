#################################################################
# S3 Bucket
#################################################################
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "uptoyoushop-bk" {
  for_each = var.s3_bucket

  bucket = "${each.value.bucket_name}-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.common_tags, {
    Name = each.value.bucket_tag_name
  })
}

#################################################################
# S3 Bucket Encryption
#################################################################
resource "aws_s3_bucket_server_side_encryption_configuration" "uptoyoushop-bk-encrypt" {
  for_each = aws_s3_bucket.uptoyoushop-bk

  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#################################################################
# S3 Bucket Public Access Block
#################################################################
resource "aws_s3_bucket_public_access_block" "uptoyoushop-bk-public" {
  for_each = aws_s3_bucket.uptoyoushop-bk

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


################################################################################
# S3 POLICY FOR APP PODS 
################################################################################
resource "aws_iam_policy" "app_s3_policy" {
  name        = "${var.naming_prefix}-app-s3-upload-policy"
  description = "Policy for app to upload and read from category and product S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::uptoyoushop-category-bucket",
          "arn:aws:s3:::uptoyoushop-category-bucket/*",
          "arn:aws:s3:::uptoyoushop-product-bucket",
          "arn:aws:s3:::uptoyoushop-product-bucket/*"
        ]
      }
    ]
  })
}



