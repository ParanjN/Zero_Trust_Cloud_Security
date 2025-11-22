# OpenSearch domain (for SIEM)
resource "aws_opensearch_domain" "siem" {
  domain_name     = var.opensearch_domain_name
  engine_version  = "OpenSearch_2.7"
  cluster_config {
    instance_type  = "t3.small.search"
    instance_count = 2
  }
  ebs_options { ebs_enabled = true; volume_size = 20 }
  node_to_node_encryption { enabled = true }
  encryption_at_rest { enabled = true; kms_key_id = aws_kms_key.log_kms.arn }
  domain_endpoint_options { enforce_https = true }
}

# IAM role for Firehose to write to OpenSearch & S3
data "aws_iam_policy_document" "firehose_assume" {
  statement { actions = ["sts:AssumeRole"]; principals { type = "Service"; identifiers = ["firehose.amazonaws.com"] } }
}
resource "aws_iam_role" "firehose_role" {
  name               = "firehose-role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume.json
}

resource "aws_iam_policy" "firehose_policy" {
  name = "firehose-access-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["es:ESHttpPost","es:ESHttpPut"], Resource = ["${aws_opensearch_domain.siem.arn}/*"] },
      { Effect = "Allow", Action = ["s3:PutObject","s3:AbortMultipartUpload"], Resource = ["${aws_s3_bucket.log_bucket.arn}/*"] }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "firehose_attach_policy" { role = aws_iam_role.firehose_role.name; policy_arn = aws_iam_policy.firehose_policy.arn }

# Kinesis Firehose delivery stream to OpenSearch with S3 backup
resource "aws_kinesis_firehose_delivery_stream" "to_opensearch" {
  name        = "logs-to-opensearch"
  destination = "opensearch"

  opensearch_configuration {
    domain_arn = aws_opensearch_domain.siem.arn
    index_name = "cloudtrail-%{+YYYY.MM.dd}"
    role_arn   = aws_iam_role.firehose_role.arn
  }

  s3_configuration {
    role_arn           = aws_iam_role.firehose_role.arn
    bucket_arn         = aws_s3_bucket.log_bucket.arn
    buffering_size     = 5
    compression_format = "GZIP"
  }
}
