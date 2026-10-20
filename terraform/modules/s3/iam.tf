#################################################################
# S3 ROLE
#################################################################
resource "aws_iam_role" "app_s3_role" {
  name = "${var.naming_prefix}-app-s3-upload-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.eks.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:default:app-s3-sa"
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "app-s3-upload-role"
  })
}

################################################################################
# S3 POLICY 
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
          aws_s3_bucket.category_bucket.arn,
          "${aws_s3_bucket.category_bucket.arn}/*",
          aws_s3_bucket.product_bucket.arn,
          "${aws_s3_bucket.product_bucket.arn}/*"
        ]
      }
    ]
  })
}

################################################################################
# S3 ROLE POLICY ATTACHMENT 
################################################################################
resource "aws_iam_role_policy_attachment" "app_s3_policy_attach" {
  role       = aws_iam_role.app_s3_role.name
  policy_arn = aws_iam_policy.app_s3_policy.arn
}
