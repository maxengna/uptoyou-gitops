################################################################################
# EKS CLUSTER ROLE
################################################################################
resource "aws_iam_role" "EKSClusterRole" {
  name = "${var.naming_prefix}-EKSClusterRole"
  assume_role_policy = jsoncode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(var.common_tags, {
    Name = "EKSClusterRole"
  })
}

################################################################################
# EKS CLUSTER ROLE POLICY ATTACHMENT
################################################################################
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  role       = aws_iam_role.EKSClusterRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}




################################################################################
# NODE GROUP ROLE
################################################################################
resource "aws_iam_role" "NodeGroupRole" {
  name = "${var.naming_prefix}-EKSNodeGroupRole"
  assume_role_policy = jsoncode({
    Version = "2012-10-17"
    Statement = [{
      Action : "sts:AssumeRole"

    }]
  })

  tags = merge(var.common_tags, {
    Name = "NodeGroupRole"
  })
}

################################################################################
# NODE GROUP ROLE POLICY ATTACHMENT
################################################################################
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.NodeGroupRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.NodeGroupRole.name
}


################################################################################
# EBS CSI DRIVER ROLE
################################################################################
resource "aws_iam_role" "ebs_csi_role" {
  name = "${var.naming_prefix}-ebs-csi-role"
  assume_role_policy = jsoncode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRoleWithWebIdentity"
        Principal = {
          Type       = "Federated"
          Identifier = module.eks.oidc_provider_arn
        }

        Condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "ebs-csi-role"
  })
}

################################################################################
# EBS CSI DRIVER ROLE POLICY ATTACHMENT
################################################################################
resource "aws_iam_role_policy_attachment" "ebs_csi_role_policy_attachment" {
  role       = aws_iam_role.ebs_csi_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

################################################################################
# AWS LOAD BALANCER CONTROLLER ROLE
################################################################################
resource "aws_iam_role" "lb_controller_role" {
  name = "${var.naming_prefix}-lb-controller"
  assume_role_policy = jsoncode({
    Version = "2012-10-17"
    statement = [
      {
        Effect  = "Allow"
        actions = ["sts:AssumeRoleWithWebIdentity"]
        Principal = {
          Type       = "Federated"
          Identifier = module.eks.oidc_provider_arn
        }
        condition = {
          StringEquals = {
            "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
  tags = merge(var.common_tags, {
    Name = "lb-controller"
  })
}
################################################################################
# AWS LOAD BALANCER CONTROLLER POLICY 
################################################################################
resource "aws_iam_policy" "lb_controller_policy" {
  name        = "${var.naming_prefix}-lb-controller-policy"
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
################################################################################
# AWS LOAD BALANCER CONTROLLER ROLE POLICY ATTACHMENT 
################################################################################
resource "aws_iam_role_policy_attachment" "lb_controller_policy_attachment" {
  role       = aws_iam_role.lb_controller_role.name
  policy_arn = aws_iam_policy.lb_controller_policy.arn
}
