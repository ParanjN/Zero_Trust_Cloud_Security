# KMS key for encrypting logs and OpenSearch at rest
resource "aws_kms_key" "log_kms" {
  description             = "KMS key for log encryption"
  deletion_window_in_days = 30
}

data "aws_caller_identity" "current" {}

# Central log S3 bucket (Object Lock enabled for forensic retention)
resource "aws_s3_bucket" "log_bucket" {
  bucket = var.log_bucket_name
  acl    = "private"

  versioning { enabled = true }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.log_kms.arn
      }
    }
  }

  object_lock_configuration {
    object_lock_enabled = "Enabled"
    rule {
      default_retention {
        mode = "GOVERNANCE"
        days = 365
      }
    }
  }

  tags = {
    Name = "org-log-archive"
  }
}

# Forensics bucket (WORM)
resource "aws_s3_bucket" "forensics_bucket" {
  bucket = var.forensic_bucket_name
  acl    = "private"
  versioning { enabled = true }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.log_kms.arn
      }
    }
  }
  object_lock_configuration {
    object_lock_enabled = "Enabled"
    rule {
      default_retention { mode = "GOVERNANCE"; days = 365 }
    }
  }
  tags = { Name = "forensics-bucket" }
}

# Organization CloudTrail (create in management account)
resource "aws_cloudtrail" "org_trail" {
  depends_on = [aws_s3_bucket.log_bucket]
  name                          = "organization-trail"
  is_multi_region_trail         = true
  include_global_service_events = true
  is_organization_trail         = true
  s3_bucket_name                = aws_s3_bucket.log_bucket.id
  enable_log_file_validation    = true
  kms_key_id                    = aws_kms_key.log_kms.arn
}
