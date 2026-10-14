variable "naming_prefix" {
  type        = string
  description = "Naming prefix for all resources."
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
    # egress = list(object({
    #   description      = string
    #   protocol         = string
    #   from_port        = number
    #   to_port          = number
    #   cidr_blocks      = list(string)
    #   ipv6_cidr_blocks = list(string)
    # }))
  }))
  description = "List of security groups with ingress rules"
}
