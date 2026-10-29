variable "naming_prefix" {
  type        = string
  description = "naming prefix for S3"
}

variable "oidc_provider_arn" {
  type        = string
  description = "The ARN of the OIDC Provider"
}


variable "oidc_provider_url" {
  type        = string
  description = "The URL of the OIDC Provider"
}
