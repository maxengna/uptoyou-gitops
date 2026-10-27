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
