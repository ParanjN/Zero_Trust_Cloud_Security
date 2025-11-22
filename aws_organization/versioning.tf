resource "aws_s3_bucket_versioning" "log_archive" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.log_archive[0].id
  versioning_configuration {
    status = "Enabled"
  }
}