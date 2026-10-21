variable "common_tags" {
  type        = map(string)
  description = "common tags for all resources"
}

variable "naming_prefix" {
  type        = string
  description = "naming prefix for S3"
}

variable "s3_bucket" {
  type = map(object({
    bucket_name     = string
    bucket_tag_name = string
  }))
}


