provider "aws" {
  region = var.region
}

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

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

#################################################################
# EKS Cluster
#################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.public_subnets

  # Node group (managed)
  eks_managed_node_groups = {
    public-nodes = {
      instance_types = ["t3.medium"]

      min_size     = 1
      max_size     = 2
      desired_size = 1

      # 🔥 สำคัญ: ให้ node มี public IP
      subnet_ids = module.vpc.public_subnets

      labels = {
        role = "public-node"
      }
    }
  }

  tags = {
    Environment = "dev"
  }
}

#################################################################
# OIDC Provider for IRSA
#################################################################
data "tls_certificate" "eks" {
  url = module.eks.cluster_oidc_issuer_url
}

resource "aws_iam_openid_connect_provider" "eks" {
  url             = module.eks.cluster_oidc_issuer_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
}

#################################################################
# IAM Role for EBS CSI Driver
#################################################################
data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.cluster_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  name               = "${var.cluster_name}-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = {
    Name        = "${var.cluster_name}-ebs-csi-role"
    Environment = "dev"
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
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${module.eks.cluster_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "lb_controller_role" {
  name               = "${var.cluster_name}-aws-load-balancer-controller-role"
  assume_role_policy = data.aws_iam_policy_document.lb_controller_assume_role.json

  tags = {
    Name        = "${var.cluster_name}-aws-load-balancer-controller-role"
    Environment = "dev"
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
          "ec2:ModifyInstanceAttribute",
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
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_role.arn

  depends_on = [aws_iam_role_policy_attachment.ebs_csi_policy_attach]

  tags = {
    Name        = "${var.cluster_name}-ebs-csi-driver"
    Environment = "dev"
    Terraform   = "true"
  }
}

# CoreDNS Addon
resource "aws_eks_addon" "coredns" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "coredns"
  addon_version               = "v1.10.1-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
}

# AWS Load Balancer Controller Addon
resource "aws_eks_addon" "aws_load_balancer_controller" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "aws-load-balancer-controller"
  addon_version               = "v2.9.1-eksbuild.1"
  resolve_conflicts_on_update = "PRESERVE"
  service_account_role_arn    = aws_iam_role.lb_controller_role.arn

  depends_on = [aws_iam_role_policy_attachment.lb_controller_policy_attach]
}
