variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "log_bucket_name" {
  type        = string
  description = "S3 bucket for centralized logs (must be globally unique)"
  default     = "org-log-archive-example-12345"
}

variable "forensic_bucket_name" {
  type        = string
  description = "S3 bucket for forensic evidence (Object Lock)"
  default     = "forensics-bucket-example-12345"
}

variable "opensearch_domain_name" {
  type    = string
  default = "siem-opensearch"
}

variable "vpc_ids" {
  type = list(string)
  description = "List of VPC IDs to enable flow logs for (provide as var or via terraform.tfvars)"
  default = []
}

variable "flow_log_destination_type" {
  type    = string
  default = "s3" # or 'cloud-watch-logs' or 'kinesis'
}
