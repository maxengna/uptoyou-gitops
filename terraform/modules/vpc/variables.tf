variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all resources."
}

variable "common_tags" {
  type        = map(string)
  description = "common tags for all resources"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
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








