provider "aws" {
  region = var.region
}

#################################################################
# Get Current AWS Account ID
#################################################################
data "aws_caller_identity" "current" {}

#################################################################
# VPC (ใช้ module สำเร็จรูป)
#################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "eks-vpc"

  cidr = "10.0.0.0/16"

  azs            = ["ap-southeast-1a", "ap-southeast-1b"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  # public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true
  # single_nat_gateway = false

  map_public_ip_on_launch = true # Auto-assign public IP to EC2 instances in public subnets

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Environment                                 = "production"
  }
}

#################################################################
# EKS Cluster
#################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  # 🔥 บรรทัดที่ 1: ให้คนรัน Terraform รอบนี้มีสิทธิ์ Admin ทันที
  enable_cluster_creator_admin_permissions = true

  # 🔥 บรรทัดที่ 2: ตั้งค่าโหมดการจัดการสิทธิ์ให้ทันสมัย (สำหรับ 1.31)
  authentication_mode = "API_AND_CONFIG_MAP"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  # Node group (managed)
  eks_managed_node_groups = {
    public-nodes = {
      instance_types = ["t3.large"]

      min_size     = 1
      max_size     = 3
      desired_size = 1

      # 🔥 สำคัญ: ให้ node มี public IP
      subnet_ids = module.vpc.public_subnets

      labels = {
        role = "public-node"
      }
    }

  }

  tags = {
    Environment = "production"
  }

  # ปิดการสร้าง CloudWatch Log Group เพื่อไม่ให้สร้างซ้ำซ้อน
  create_cloudwatch_log_group = false

}

#################################################################
# OIDC Provider - ใช้ที่ EKS module สร้างให้แล้ว
#################################################################
data "aws_iam_openid_connect_provider" "eks" {
  arn = module.eks.oidc_provider_arn
}

#################################################################
# IAM Role for EBS CSI Driver
#################################################################
data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      # variable = "${module.eks.cluster_oidc_issuer_url}:sub"
      values = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  name               = "${var.cluster_name}-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = {
    Name        = "${var.cluster_name}-ebs-csi-role"
    Environment = "production"
  }
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attach" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = data.aws_iam_policy.ebs_csi_policy.arn
}

#################################################################
# IAM Role for AWS Load Balancer Controller
#################################################################
data "aws_iam_policy_document" "lb_controller_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test = "StringEquals"
      # variable = "${module.eks.cluster_oidc_issuer_url}:sub"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "lb_controller_role" {
  name               = "${var.cluster_name}-aws-load-balancer-controller-role"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_assume_role.json

  tags = {
    Name        = "${var.cluster_name}-aws-load-balancer-controller-role"
    Environment = "production"
  }
}

resource "aws_iam_policy" "lb_controller_policy" {
  name        = "${var.cluster_name}-aws-load-balancer-controller-policy"
  description = "Policy for AWS Load Balancer Controller"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:*",
          "ec2:Describe*",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifyNetworkInterfaceAttribute",
          "iam:CreateServiceLinkedRole",
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lb_controller_policy_attach" {
  role       = aws_iam_role.lb_controller_role.name
  policy_arn = aws_iam_policy.lb_controller_policy.arn
}

#################################################################
# EKS Addons
#################################################################

# EBS CSI Driver Addon
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.ebs_csi_role.arn
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [aws_iam_role_policy_attachment.ebs_csi_policy_attach]

  tags = {
    Name        = "${var.cluster_name}-ebs-csi-driver"
    Environment = "production"
    Terraform   = "true"
  }
}

# CoreDNS Addon
resource "aws_eks_addon" "coredns" {
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"
  # addon_version               = "v1.10.1-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}

# AWS Load Balancer Controller Addon
# resource "aws_eks_addon" "aws_load_balancer_controller" {
#   cluster_name = module.eks.cluster_name
#   addon_name   = "aws-load-balancer-controller"
#   # addon_version               = "v2.9.1-eksbuild.1"
#   resolve_conflicts_on_update = "OVERWRITE"
#   service_account_role_arn    = aws_iam_role.lb_controller_role.arn

#   depends_on = [aws_iam_role_policy_attachment.lb_controller_policy_attach]
# }

#################################################################
# S3 Buckets for Category and Product
#################################################################
resource "aws_s3_bucket" "category_bucket" {
  bucket = "uptoyoushop-category-bucket-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name        = "UpToYouShop Category"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "category_bucket" {
  bucket = aws_s3_bucket.category_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "category_bucket" {
  bucket = aws_s3_bucket.category_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "product_bucket" {
  bucket = "uptoyoushop-product-bucket-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name        = "UpToYouShop Product"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "product_bucket" {
  bucket = aws_s3_bucket.product_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "product_bucket" {
  bucket = aws_s3_bucket.product_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#################################################################
# IAM Role for App S3 Upload
#################################################################
resource "aws_iam_role" "app_s3_role" {
  name = "${var.cluster_name}-app-s3-upload-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = data.aws_iam_openid_connect_provider.eks.arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:default:app-s3-sa"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.cluster_name}-app-s3-upload-role"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "app_s3_policy" {
  name        = "${var.cluster_name}-app-s3-upload-policy"
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

resource "aws_iam_role_policy_attachment" "app_s3_policy_attach" {
  role       = aws_iam_role.app_s3_role.name
  policy_arn = aws_iam_policy.app_s3_policy.arn
}

#################################################################
# AWS SES Configuration with IRSA
#################################################################

# SES Domain Identity
# ระบุชื่อโดเมนที่จะใช้กับ AWS SES เพื่อยืนยันความเป็นเจ้าของโดเมน
# resource "aws_ses_domain_identity" "mail_domain" {
  # domain = var.ses_domain
# }

# SES DKIM
# สร้าง DKIM token สำหรับการตรวจสอบ DNS ของโดเมน
# resource "aws_ses_domain_dkim" "mail_domain" {
  # domain = aws_ses_domain_identity.mail_domain.domain
# }

#################################################################
# IAM Role for SES (IRSA)
#################################################################
# สร้าง IAM policy document เพื่ออนุญาตให้ Kubernetes service account assume role ผ่าน OIDC
# โดยจำกัดให้เฉพาะ service account ใน namespace และชื่อที่กำหนดเท่านั้น
# data "aws_iam_policy_document" "ses_assume_role" {
#  statement {
#    actions = ["sts:AssumeRoleWithWebIdentity"]
#    principals {
#      type        = "Federated"
#      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
#    }
#    condition {
#      test     = "StringEquals"
#      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
#      values   = ["system:serviceaccount:${var.ses_namespace}:${var.ses_service_account}"]
#    }
#  }
#}

# สร้าง IAM role สำหรับ SES service account ที่ระบุไว้
#resource "aws_iam_role" "ses_role" {
#  name               = "${var.cluster_name}-ses-role"
#  assume_role_policy = data.aws_iam_policy_document.ses_assume_role.json

#  tags = {
#    Name        = "${var.cluster_name}-ses-role"
#    Environment = var.environment
#  }
#}

#################################################################
# IAM Policy for SES
#################################################################
# นโยบายสำหรับการอนุญาตให้ SES สามารถส่งอีเมลและดูข้อมูลควอต้า/สถิติเกี่ยวกับการส่งได้
#resource "aws_iam_policy" "ses_policy" {
#  name        = "${var.cluster_name}-ses-policy"
#  description = "Policy for SES email sending"

#  policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#      {
#        Effect = "Allow"
#        Action = [
#          "ses:SendEmail",
#          "ses:SendRawEmail",
#          "ses:GetSendQuota",
#          "ses:GetSendStatistics",
#          "ses:ListVerifiedEmailAddresses",
#          "ses:ListConfigurationSets",
#          "ses:GetConfigurationSetDeliveryOptions"
#        ]
#        Resource = "*"
#      }
#    ]
#  })
#}

# ผูกนโยบาย SES เข้ากับ IAM role เพื่อให้ service account สามารถใช้งาน SES ได้
#resource "aws_iam_role_policy_attachment" "ses_policy_attach" {
#  role       = aws_iam_role.ses_role.name
#  policy_arn = aws_iam_policy.ses_policy.arn
#}



#################################################################
# IAM Role for Exter Secret Operator
#################################################################
data "aws_iam_policy_document" "external_secrets_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:uptoyoushop:external-secrets"]
    }
  }
}

resource "aws_iam_role" "external_secrets_role" {
  name               = "${var.cluster_name}-external-secrets-role"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role.json

  tags = {
    Name        = "${var.cluster_name}-external-secrets-role"
    Environment = var.environment
  }
}



#################################################################
# IAM Policy for External Secret Operator
#################################################################
resource "aws_iam_policy" "external_secrets_policy" {
  name        = "${var.cluster_name}-external-secrets-policy"
  description = "Allow External Secrets Operator to read from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "external_secrets_policy_attach" {
  role       = aws_iam_role.external_secrets_role.name
  policy_arn = aws_iam_policy.external_secrets_policy.arn
}
