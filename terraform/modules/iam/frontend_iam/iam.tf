#################################################################
# FRONTEND ROLE
#################################################################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "frontend_role" {
  name = "${var.naming_prefix}-frontend-role"
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
          "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:uptoyoushop:frontend-sa"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "frontend-role"
  })
}

################################################################################
# FRONTEND SECRETS ROLE POLICY ATTACHMENT 
################################################################################
resource "aws_iam_role_policy_attachment" "frontend_role_policy_attachment" {
  role       = aws_iam_role.frontend_role.name
  policy_arn = var.external_secrets_policy_arn
}

################################################################################
# FRONTEND ECR ROLE POLICY ATTACHMENT 
################################################################################
resource "aws_iam_role_policy_attachment" "frontend_ecr_policy_attachment" {
  role       = aws_iam_role.frontend_role.name
  policy_arn = var.frontend_ecr_policy_arn
}


################################################################################
# FRONTEND SERVICE ACCOUNT 
################################################################################
resource "kubernetes_service_account" "frontend_sa" {
  metadata {
    name      = "frontend-sa"
    namespace = "uptoyoushop"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.frontend_role.arn
    }
  }
}


