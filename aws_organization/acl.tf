resource "aws_s3_bucket_acl" "log_archive" {
  count     = var.create_log_bucket ? 1 : 0
  depends_on = [aws_s3_bucket_ownership_controls.log_archive[0], time_sleep.wait_for_bucket_ownership]
  bucket    = aws_s3_bucket.log_archive[0].id
  acl       = "private"
}