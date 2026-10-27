#################################################################
# BACKEND ROLE
#################################################################
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_iam_role" "backend_role" {
  name = "${var.naming_prefix}-backend-role"
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
          "${replace(var.oidc_provider_url, "https://", "")}:sub" = "system:serviceaccount:uptoyoushop:backend-sa"
        }
      }
    }]
  })

  tags = merge(var.common_tags, {
    Name = "backend-role"
  })
}

################################################################################
# BACKEND SECRETS ROLE POLICY ATTACHMENT 
################################################################################
resource "aws_iam_role_policy_attachment" "backend_secrets_policy_attachment" {
  role       = aws_iam_role.backend_role.name
  policy_arn = var.external_secrets_policy_arn
}

################################################################################
# BACKEND S3 ROLE POLICY ATTACHMENT 
################################################################################
resource "aws_iam_role_policy_attachment" "backend_s3_policy_attachment" {
  role       = aws_iam_role.backend_role.name
  policy_arn = var.app_s3_policy_arn
}

################################################################################
# BACKEND ECR ROLE POLICY ATTACHMENT 
################################################################################
resource "aws_iam_role_policy_attachment" "backend_ecr_policy_attachment" {
  role       = aws_iam_role.backend_role.name
  policy_arn = var.backend_ecr_policy_arn
}


################################################################################
# BACKEND SERVICE ACCOUNT 
################################################################################
resource "kubernetes_service_account" "backend_sa" {
  metadata {
    name      = "backend-sa"
    namespace = "uptoyoushop"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.backend_role.arn
    }
  }
}
