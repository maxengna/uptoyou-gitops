
################################################################################
# ECR POLICY FOR PULL BACKEND IMAGES
################################################################################
resource "aws_iam_policy" "backend_ecr_policy" {
  name        = "${var.naming_prefix}-backend-ecr-policy"
  description = "Allow pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
        ]
        Resource = [
          "arn:aws:ecr:ap-southeast-1:575108951885:repository/uptoyoushop-backend"
        ]
      }
    ]
  })
}

################################################################################
# ECR POLICY FOR PULL FRONTEND IMAGES
################################################################################
resource "aws_iam_policy" "frontend_ecr_policy" {
  name        = "${var.naming_prefix}-frontend-ecr-policy"
  description = "Allow pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
        ]
        Resource = [
          "arn:aws:ecr:ap-southeast-1:575108951885:repository/uptoyoushop-frontend"
        ]
      }
    ]
  })
}

