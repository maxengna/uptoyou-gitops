#################################################################
# DB SECRETS ROLE
#################################################################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "db_secrets_role" {
  name = "${var.naming_prefix}-db-secrets-role"
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
          "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:uptoyoushop:db-secrets-sa"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "db-secrets-role"
  })
}

################################################################################
# DB SECRETS POLICY
################################################################################
resource "aws_iam_policy" "db_secrets_policy" {
  name        = "${var.naming_prefix}-db-secrets-policy"
  description = "Allow db pods to read from AWS Secrets Manager"

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
          "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:postgres/uptoyoushop-*"
        ]
      }
    ]
  })
}

################################################################################
# DB SECRETS ROLE POLICY ATTACHMENT 
################################################################################
resource "aws_iam_role_policy_attachment" "db_secrets_policy_attachment" {
  role       = aws_iam_role.db_secrets_role.name
  policy_arn = aws_iam_policy.db_secrets_policy.arn
}
