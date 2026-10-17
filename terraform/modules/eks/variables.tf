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

variable "security_groups_id" {
  type        = list(string)
  description = "security group id"
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


variable "public_subnets_ids" {
  type        = list(string)
  description = "public subnet id"
}


variable "addons" {
  type = map(object({
    name        = string
    version     = optional(string)
    most_recent = optional(bool)
    # resolve_conflicts = optional(string)
    # resolve_conflicts_on_update = optional(string)
  }))
  description = "map of eks addons"
}


