output "vpc_id" {
  value = aws_vpc.uptoyoushop-main.id
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnets_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "security_groups_id" {
  value = { for k, v in aws_security_group.uptoyoushop-sg : k => v.id }
}

