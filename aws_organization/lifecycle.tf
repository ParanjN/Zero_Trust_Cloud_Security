resource "aws_s3_bucket_lifecycle_configuration" "log_archive" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.log_archive[0].id

  rule {
    id     = "log-archive-life"
    status = "Enabled"

    expiration {
      days = 2555  # 7 years
    }
  }
}