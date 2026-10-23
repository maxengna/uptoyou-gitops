################################################################################
# EXTERNAL SECRETS OPERATOR POLICY
################################################################################
resource "aws_iam_policy" "external_secrets_policy" {
  name        = "${var.naming_prefix}-external-secrets-policy"
  description = "Allow external secrets operator to read from AWS Secrets Manager"

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
