################################################################################
# EKS Cluster
################################################################################
resource "aws_eks_cluster" "uptoyoushop-eks-cluster" {
  name     = var.cluster_config.name
  role_arn = aws_iam_role.EKSClusterRole.arn
  version  = var.cluster_config.version

  vpc_config {
    subnet_ids = flatten(module.vpc.public_subnets_ids)
    security_group_ids = [
      module.vpc.security_groups_id
    ]
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

