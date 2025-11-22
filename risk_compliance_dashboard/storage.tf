# S3 bucket to aggregate findings and scored results
resource "aws_s3_bucket" "findings_bucket" {
  bucket = "${var.project_prefix}-dashboard-${random_id.suffix.hex}"

  tags = {
    Project = var.project_prefix
  }
}

# Separate server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "findings_bucket_encryption" {
  bucket = aws_s3_bucket.findings_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Separate versioning configuration
resource "aws_s3_bucket_versioning" "findings_bucket_versioning" {
  bucket = aws_s3_bucket.findings_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Separate ACL configuration
resource "aws_s3_bucket_acl" "findings_bucket_acl" {
  bucket = aws_s3_bucket.findings_bucket.id
  acl    = "private"

  depends_on = [aws_s3_bucket_ownership_controls.findings_bucket_ownership]
}

# Bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "findings_bucket_ownership" {
  bucket = aws_s3_bucket.findings_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.findings_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Glue Catalog & Athena Configuration
resource "aws_glue_catalog_database" "findings_db" {
  name        = "${var.project_prefix}_db"
  description = "Glue DB for aggregated security findings"
}

resource "aws_glue_crawler" "findings_crawler" {
  name          = "${var.project_prefix}-findings-crawler-${random_id.suffix.hex}"
  database_name = aws_glue_catalog_database.findings_db.name
  role          = aws_iam_role.glue_crawler_role.arn
  
  s3_target {
    path = "s3://${aws_s3_bucket.findings_bucket.bucket}/scored/"
  }
}

resource "aws_athena_workgroup" "wg" {
  name = "${var.project_prefix}-wg"
  
  configuration {
    enforce_workgroup_configuration = true
    result_configuration {
      output_location = "s3://${aws_s3_bucket.findings_bucket.bucket}/athena/results/"
    }
  }
}