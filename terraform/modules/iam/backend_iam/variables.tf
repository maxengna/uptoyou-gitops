variable "common_tags" {
  type        = map(string)
  description = "common tags for all resources"
}

variable "naming_prefix" {
  type        = string
  description = "naming prefix for S3"
}

variable "oidc_provider_arn" {
  type        = string
  description = "OIDC provider ARN"
}

variable "oidc_provider_url" {
  type        = string
  description = "OIDC provider URL"
}

variable "external_secrets_policy_arn" {
  type        = string
  description = "External Secrets Operator policy ARN"
}

variable "app_s3_policy_arn" {
  type        = string
  description = "App S3 policy ARN"
}

variable "backend_ecr_policy_arn" {
  type        = string
  description = "Backend ECR policy ARN"
}
