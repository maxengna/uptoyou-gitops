#################################################################
# BACKEND SECRETS ROLE
#################################################################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "backend_secrets_role" {
  name = "${var.naming_prefix}-backend-secrets-role"
  assume_role_policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:uptoyoushop:backend-s3-sa"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "backend-secrets-role"
  })
}

################################################################################
# BACKEND SECRETS POLICY
################################################################################
resource "aws_iam_policy" "backend_secrets_policy" {
  name        = "${var.naming_prefix}-backend-secrets-policy"
  description = "Allow backend pods to read from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:credential/uptoyoushop-*",
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:stripe/uptoyoushop-*"
        ]
      }
    ]
  })
}

################################################################################
# BACKEND SECRETS ROLE POLICY ATTACHMENT 
################################################################################
resource "aws_iam_role_policy_attachment" "backend_secrets_policy_attachment" {
  role       = aws_iam_role.backend_secrets_role.name
  policy_arn = aws_iam_policy.backend_secrets_policy.arn
}
