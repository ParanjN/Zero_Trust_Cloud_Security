output "log_bucket" { value = aws_s3_bucket.log_bucket.id }
output "forensics_bucket" { value = aws_s3_bucket.forensics_bucket.id }
output "opensearch_endpoint" { value = aws_opensearch_domain.siem.endpoint }
output "firehose_name" { value = aws_kinesis_firehose_delivery_stream.to_opensearch.name }
