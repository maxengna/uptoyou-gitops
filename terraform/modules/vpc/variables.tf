variable "naming_prefix" {}

variable "public_subnet_cidr" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "private_subnet_cidr" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}


variable "azs" {
  type        = list(string)
  description = "Availability Zone"
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "security_groups" {
  description = "Security groups configuration passed from root module"
}

