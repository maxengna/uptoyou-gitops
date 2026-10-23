################################################################################
# BACKEND ECR REPOSITORY
################################################################################
resource "aws_ecr_repository" "backend" {
  name                 = "${var.naming_prefix}-backend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.common_tags, {
    Name = "backend"
  })
}

################################################################################
# FRONTEND ECR REPOSITORY
################################################################################
resource "aws_ecr_repository" "frontend" {
  name                 = "${var.naming_prefix}-frontend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge(var.common_tags, {
    Name = "frontend"
  })
}
