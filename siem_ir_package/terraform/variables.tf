variable "aws_region" { type = string, default = "us-east-1" }
variable "aws_profile" { type = string, default = "default" }

variable "forensic_bucket_name" {
  description = "S3 bucket for forensic evidence (object lock enabled)"
  type = string
  default = "forensics-bucket-example-12345"
}

variable "lambda_timeout" {
  type = number
  default = 60
}

variable "opensearch_domain_endpoint" {
  description = "OpenSearch Dashboards endpoint (https://...)"
  type = string
  default = ""
}
