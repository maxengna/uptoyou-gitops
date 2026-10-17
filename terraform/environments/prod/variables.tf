variable "aws_region" {
  type        = string
  description = "region for aws resources"
}

variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all resources."
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block."
}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "Public Subnet CIDR values"
}

variable "private_subnet_cidr" {
  type        = list(string)
  description = "Private Subnet CIDR values"
}

variable "public_rt_cidr" {
  type        = string
  description = "public route table CIDR values"
}

variable "azs" {
  type        = list(string)
  description = "Availability Zone"
}



variable "security_groups" {
  type = list(object({
    name        = string
    description = string
    ingress = list(object({
      description      = string
      protocol         = string
      from_port        = number
      to_port          = number
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
    }))
    egress = list(object({
      description      = string
      protocol         = string
      from_port        = number
      to_port          = number
      cidr_blocks      = list(string)
      ipv6_cidr_blocks = list(string)
    }))
  }))
  description = "List of security groups with ingress rules"
}


variable "cluster_config" {
  type = object({
    name    = string
    version = string
  })
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
  description = "List of node groups with configuration"
}


variable "public_subnets_ids" {
  type        = list(string)
  description = "public subnet id"
}

