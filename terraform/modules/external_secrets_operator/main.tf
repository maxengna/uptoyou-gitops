################################################################################
# EXTERNAL SECRETS OPERATOR ROLE
################################################################################
resource "aws_iam_role" "external_secrets_role" {
  name = "${var.naming_prefix}-external-secrets-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = var.oidc_provider_arn
      }
      Condition = {
        StringEquals = {
          "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:uptoyoushop:external-secrets-sa"
        }
      }
    }]
  })
}

################################################################################
# EXTERNAL SECRETS OPERATOR POLICY
################################################################################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

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
          "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:credential/uptoyoushop-*",
          "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:stripe/uptoyoushop-*",
          "arn:aws:secretsmanager:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:secret:postgres/uptoyoushop-*"
        ]
      }
    ]
  })
}

################################################################################
# EXTERNAL SECRETS OPERATOR ROLE POLICY ATTACHMENT
################################################################################
resource "aws_iam_role_policy_attachment" "external_secrets_attachment" {
  role       = aws_iam_role.external_secrets_role.name
  policy_arn = aws_iam_policy.external_secrets_policy.arn
}
