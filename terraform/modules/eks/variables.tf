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

variable "public_subnets_id" {
  type        = list(string)
  description = "Public Subnet IDs"
}

variable "security_groups_id" {
  type        = list(string)
  description = "Security Group IDs"
}

variable "node_groups" {
  type = list(object({
    name           = string
    instance_types = list(string)
    ami_type       = string
    capacity_type  = string
    disk_size      = number
    scaling_config = object({
      desired_size = number
      min_size     = number
      max_size     = number
    })

    update_config = object({
      max_unavailable = number
    })

  }))
}

variable "standard_addons" {
  type = map(object({
    name        = string
    version     = optional(string)
    most_recent = optional(bool)
  }))
  description = "map of eks standard addons"
}


variable "ebs_csi" {
  type = map(object({
    name                     = string
    version                  = optional(string)
    most_recent              = optional(bool)
    service_account_role_arn = optional(string)
  }))
  description = "map of ebs-csi addons"
}


