################################################################################
# EKS Cluster
################################################################################
resource "aws_eks_cluster" "uptoyoushop-eks-cluster" {
  name     = var.cluster_config.name
  role_arn = aws_iam_role.EKSClusterRole.arn
  version  = var.cluster_config.version

  vpc_config {
    subnet_ids         = var.public_subnets_id
    security_group_ids = var.security_groups_id
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]

  tags = merge(var.common_tags, {
    Name = "uptoyoushop-eks-cluster"
  })
}

################################################################################
# NODE GROUP
################################################################################
resource "aws_eks_node_group" "uptoyoushop-node-group" {
  for_each        = { for node_group in var.node_groups : node_group.name => node_group }
  cluster_name    = aws_eks_cluster.uptoyoushop-eks-cluster.name
  node_group_name = "${var.naming_prefix}-${each.value.name}"
  node_role_arn   = aws_iam_role.NodeGroupRole.arn
  subnet_ids      = flatten(module.vpc.public_subnets_ids)

  scaling_config {
    desired_size = try(each.value.scaling_config.desired_size, 1)
    min_size     = try(each.value.scaling_config.min_size, 1)
    max_size     = try(each.value.scaling_config.max_size, 1)
  }

  update_config {
    max_unavailable = try(each.value.update_config.max_unavailable, 1)
  }

  ami_type       = each.value.ami_type
  instance_types = each.value.instance_types
  capacity_type  = each.value.capacity_type
  disk_size      = each.value.disk_size
  version        = each.value.version

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-nodes-${each.value.name}"
  })

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
  ]

}


resource "aws_iam_openid_connect_provider" "eks-oidc-provider" {
  url            = aws_eks_cluster.uptoyoushop-eks-cluster.identity[0].oidc[0].issuer
  client_id_list = ["sts.amazonaws.com"]

  tags = merge(var.common_tags, {
    Name = "eks-oidc-provider"
  })
}

################################################################################
# EKS Addons : KUBE PROXEY, VPC-CNI,CoreDNS
################################################################################
data "aws_eks_addon_version" "standard_addons_version" {
  for_each = var.standard_addons

  addon_name         = each.value.name
  kubernetes_version = aws_eks_cluster.uptoyoushop-eks-cluster.version
  most_recent        = coalesce(each.value.most_recent, true)
}

resource "aws_eks_addon" "standard_addons" {
  for_each = var.standard_addons

  cluster_name                = aws_eks_cluster.uptoyoushop-eks-cluster.name
  addon_name                  = each.value.name
  addon_version               = coalesce(each.value.version, data.aws_eks_addon_version.standard_addons[each.key].version)
  service_account_role_arn    = optional(each.value.service_account_role_arn)
  resolve_conflicts_on_create = "OVERWRITE"

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-addon-${each.value.name}"
  })
  depends_on = [aws_eks_node_group.uptoyoushop-node-group]
}


################################################################################
# EXTRA EKS Addons : EBS CSI 
################################################################################
data "aws_eks_addon_version" "ebs_csi_version" {
  for_each = var.ebs_csi

  addon_name         = each.value.name
  kubernetes_version = aws_eks_cluster.uptoyoushop-eks-cluster.version
  most_recent        = coalesce(each.value.most_recent, true)
}

resource "aws_eks_addon" "ebs_csi" {
  for_each = var.ebs_csi

  cluster_name                = aws_eks_cluster.uptoyoushop-eks-cluster.name
  addon_name                  = each.value.name
  addon_version               = coalesce(each.value.version, data.aws_eks_addon_version.ebs_csi[each.key].version)
  service_account_role_arn    = optional(each.value.service_account_role_arn)
  resolve_conflicts_on_create = "OVERWRITE"

  tags = merge(var.common_tags, {
    Name = "${var.naming_prefix}-addon-${each.value.name}"
  })
  depends_on = [
    aws_eks_node_group.uptoyoushop-node-group,
    aws_iam_role.aws_iam_role.ebs_csi_role
  ]
}

