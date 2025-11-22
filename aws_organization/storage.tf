# Get existing S3 bucket if specified
data "aws_s3_bucket" "log_archive" {
  count  = var.existing_log_bucket_name != null ? 1 : 0
  bucket = var.existing_log_bucket_name
}

# Random suffix for bucket name uniqueness
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Get existing KMS key if specified
data "aws_kms_key" "logging_key" {
  count  = var.existing_kms_key_id != null ? 1 : 0
  key_id = var.existing_kms_key_id
}

# Create KMS key if needed
resource "aws_kms_key" "log_bucket_key" {
  count                   = var.create_log_bucket && var.existing_kms_key_id == null ? 1 : 0
  description             = "KMS key for CloudTrail log bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

# Create KMS alias
resource "aws_kms_alias" "log_bucket_key" {
  count         = var.create_log_bucket && var.existing_kms_key_id == null ? 1 : 0
  name          = "alias/log-archive-key-${random_string.suffix.result}"
  target_key_id = aws_kms_key.log_bucket_key[0].key_id
}

# Log Archive S3 Bucket
resource "aws_s3_bucket" "log_archive" {
  count         = var.create_log_bucket ? 1 : 0
  bucket        = "${data.aws_organizations_organization.org.id}-log-archive-${random_string.suffix.result}"
  force_destroy = false

  object_lock_enabled = true

  tags = {
    Name = "Organization Log Archive"
  }
}

# Configure bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_sse" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.log_archive[0].id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = coalesce(
        var.existing_kms_key_id,
        try(aws_kms_key.log_bucket_key[0].arn, null),
        try(data.aws_kms_key.logging_key[0].arn, null)
      )
      sse_algorithm = "aws:kms"
    }
  }
}