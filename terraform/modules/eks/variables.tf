variable "common_tags" {
  type        = map(string)
  description = "common tags for all resources"
}

variable "naming_prefix" {
  type        = string
  description = "naming prefix for all resources"
}

variable "cluster_config" {
  type = object({
    name    = string
    version = string
  })
}


