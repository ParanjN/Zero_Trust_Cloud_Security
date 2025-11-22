# Outputs for AI Threat Detection Module

output "sagemaker_endpoint_name" {
  description = "Name of the SageMaker endpoint for anomaly detection"
  value       = aws_sagemaker_endpoint.rcf_endpoint.name
}

output "glue_database_name" {
  description = "Name of the Glue catalog database"
  value       = aws_glue_catalog_database.threat_detection_db.name
}

output "sagemaker_notebook_url" {
  description = "URL of the SageMaker notebook instance"
  value       = aws_sagemaker_notebook_instance.threat_detection.url
}

output "glue_crawler_name" {
  description = "Name of the Glue crawler"
  value       = aws_glue_crawler.log_crawler.name
}