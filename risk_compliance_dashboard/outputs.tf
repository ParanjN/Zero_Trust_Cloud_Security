output "s3_bucket" {
  value       = aws_s3_bucket.findings_bucket.bucket
  description = "Name of the S3 bucket storing findings and results"
}

output "ingest_lambda_arn" {
  value       = aws_lambda_function.ingest_lambda.arn
  description = "ARN of the Lambda function ingesting security findings"
}

output "score_lambda_arn" {
  value       = aws_lambda_function.score_lambda.arn
  description = "ARN of the Lambda function scoring findings"
}

output "glue_db" {
  value       = aws_glue_catalog_database.findings_db.name
  description = "Name of the Glue database for findings"
}

# QuickSight outputs commented out until manual setup is complete
# output "quicksight_datasource_arn" {
#   value       = aws_quicksight_data_source.athena_ds.arn
#   description = "ARN of the QuickSight Athena data source"
# }