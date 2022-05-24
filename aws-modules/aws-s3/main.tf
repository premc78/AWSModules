resource "aws_s3_bucket" "bucket" {
  bucket = format("%s-%s-%s", var.customer, var.project, var.name)
  acl    = var.acl
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }

  versioning {
    enabled     = var.versioning
    mfa_delete  = var.mfa_delete
  }

  tags = var.tags
}