# Block all public access to the bucket
resource "aws_s3_bucket_public_access_block" "log_archive" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.log_archive[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}