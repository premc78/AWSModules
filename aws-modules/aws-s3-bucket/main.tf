data "aws_partition" "current" {}
locals {
  bucket_id             = "${var.business}-${var.bucket}"
  enable_bucket_logging = var.logging_bucket != ""
}

data "aws_iam_policy_document" "access_policy" {

  source_json = var.custom_bucket_policy
  #
  # Extend the custom_bucket_policy to enforce SSL/TLS on all
  #
  statement {
    sid    = "enforce-tls-requests-only"
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = ["s3:*"]
    resources = [
      "arn:${data.aws_partition.current.partition}:s3:::${local.bucket_id}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket" "private_bucket" {
  bucket = local.bucket_id
  acl    = "private"
  tags   = var.tags
  policy = data.aws_iam_policy_document.access_policy.json

  versioning {
    enabled = true
  }

  dynamic "logging" {
    for_each = local.enable_bucket_logging ? [1] : []
    content {
      target_bucket = var.logging_bucket
      target_prefix = "s3/${local.bucket_id}/"
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

#
# Block any public access to S3 
#
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.private_bucket.id

  # Block new public ACLs and uploading public objects
  block_public_acls = true

  # Retroactively remove public access granted through public ACLs
  ignore_public_acls = true

  # Block new public bucket policies
  block_public_policy = true

  # Retroactivley block public and cross-account access if bucket has public policies
  restrict_public_buckets = true
}
