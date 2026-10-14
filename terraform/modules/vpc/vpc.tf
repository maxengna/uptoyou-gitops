################################################################################
# VPC
################################################################################
resource "aws_vpc" "uptoyoushop-main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "uptoyoushop-main"
  }
}

################################################################################
# Public Subnet
################################################################################
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidr)
  vpc_id                  = aws_vpc.uptoyoushop-main.id
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = element(var.azs.id)
  map_public_ip_on_launch = true

  tags = {
    Name = "uptoyoushop-public-subnet-${count.index}"
  }
}

################################################################################
# Private Subnet
################################################################################
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidr)
  vpc_id            = aws_vpc.uptoyoushop-main.id
  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = element(var.azs.id, count.index)

  tags = {
    Name = "uptoyoushop-private-subnet-${count.index}"
  }
}

################################################################################
# Internet Gateway
################################################################################
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.uptoyoushop-main.id

  tags = {
    Name = "uptoyoushop-igw"
  }
}

################################################################################
# Route Table for public subnet
################################################################################
resource "aws_route_table" "uptoyoushop-public-rt" {
  vpc_id = aws_vpc.uptoyoushop-main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "uptoyoushop-public-rt"
  }
}

################################################################################
# Association public subnet with second route table
################################################################################
resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.public_subnet[*].id, count.index)
  route_table_id = aws_route_table.uptoyoushop-public-rt.id
}


################################################################################
# SECURITY GROUPS
################################################################################

resource "aws_security_group" "uptoyoushop-sg" {
  for_each    = { for sec in var.security_groups : sec.name => sec }
  name        = "${var.naming_prefix}-${each.value.name}"
  description = each.value.description
  vpc_id      = aws_vpc.uptoyoushop-main.id

  dynamic "ingress" {
    for_each = try(each.value.ingress, [])
    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocs

    }
  }

  # dynamic "egress" {
  #   for_each = try(each.value.egress, [])
  #   content {
  #     description      = egress.value.description
  #     from_port        = egress.value.from_port
  #     to_port          = egress.value.to_port
  #     protocol         = egress.value.protocol
  #     cidr_blocks      = egress.value.cidr_blocks
  #     ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
  #   }
  # }
}


