resource "aws_s3_bucket_ownership_controls" "log_archive" {
  count  = var.create_log_bucket ? 1 : 0
  bucket = aws_s3_bucket.log_archive[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Wait for ownership settings to propagate
resource "time_sleep" "wait_for_bucket_ownership" {
  depends_on = [aws_s3_bucket_ownership_controls.log_archive]
  create_duration = "10s"
}