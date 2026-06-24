variable "region" {
  default = "ap-southeast-1"
}

variable "cluster_name" {
  default = "uptoyou-eks-cluster"
}

variable "environment" {
  description = "Environment name"
  default     = "production"
}

variable "ses_domain" {
  description = "Domain name for SES"
  default     = "noreply.uptoyou.com"
}

variable "ses_namespace" {
  description = "Kubernetes namespace for SES service account"
  default     = "default"
}

variable "ses_service_account" {
  description = "Kubernetes service account name for SES"
  default     = "ses-sa"
}