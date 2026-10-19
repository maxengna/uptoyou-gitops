################################################################################
# EKS Cluster Outputs
################################################################################
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eks-cluster.Endpoint
}

output "cluster_name" {
  description = "EKS_cluster_name"
  value       = aws_eks_cluster.eks-cluster.name
}

output "cluster_certificate_authority_data" {
  description = "EKS_cluster_certificate_authority_data"
  value       = aws_eks_cluster.eks-cluster.certificate_authority[0].data
}

output "cluster_id" {
  description = "EKS_cluster_id"
  value       = aws_eks_cluster.eks-cluster.id
}

output "cluster_arn" {
  description = "EKS_cluster_arn"
  value       = aws_eks_cluster.eks-cluster.arn
}

output "cluster_version" {
  description = "EKS_cluster_version"
  value       = aws_eks_cluster.eks-cluster.version
}

output "cluster_security_group_id" {
  description = "EKS_cluster_security_group_id"
  value       = aws_eks_cluster.eks-cluster.vpc_config[0].security_group_ids
}

output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider for the EKS cluster"
  value       = aws_eks_cluster.eks-cluster.identity[0].oidc[0].issuer
}

output "oidc_provider_url" {
  description = "The URL of the OIDC Provider for the EKS cluster"
  value       = aws_eks_cluster.eks-cluster.identity[0].oidc[0].url
}

output "node_groups" {
  description = "Map of EKS node group information"
  value = {
    for ng_name, ng in aws_eks_node_group.uptoyoushop-node-group : ng_name => {
      arn            = ng.arn
      status         = ng.status
      capacity_type  = ng.capacity_type
      instance_types = ng.instance_types
      scaling_config = ng.scaling_config
    }
  }
}
