#################################################################
# Category Bucket
#################################################################
data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "category" {
  bucket = "uptoyoushop-category-bucket-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.common_tags, {
    Name = "Category"
  })
}

#################################################################
# Category Bucket Encryption
#################################################################
resource "aws_s3_bucket_server_side_encryption_configuration" "category" {
  bucket = aws_s3_bucket.category.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#################################################################
# Category Bucket Public Access Block
#################################################################
resource "aws_s3_bucket_public_access_block" "category" {
  bucket = aws_s3_bucket.category.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#################################################################
# Product Bucket
#################################################################
resource "aws_s3_bucket" "product" {
  bucket = "uptoyoushop-product-bucket-${data.aws_caller_identity.current.account_id}"

  tags = merge(var.common_tags, {
    Name = "Product"
  })
}

#################################################################
# Product Bucket Encryption
#################################################################
resource "aws_s3_bucket_server_side_encryption_configuration" "product" {
  bucket = aws_s3_bucket.product.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#################################################################
# Product Bucket Public Access Block
#################################################################
resource "aws_s3_bucket_public_access_block" "product" {
  bucket = aws_s3_bucket.product.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


