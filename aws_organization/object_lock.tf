resource "aws_s3_bucket_object_lock_configuration" "log_archive" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.log_archive[0].id

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 365
    }
  }
}