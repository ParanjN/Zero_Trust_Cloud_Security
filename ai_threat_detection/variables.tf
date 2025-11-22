# Variables for AI Threat Detection Module

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "ai-threat-detect"
}

variable "sagemaker_rcf_image" {
  type        = string
  description = "SageMaker RCF container URI for your region"
  default     = ""
}

variable "sagemaker_instance_type" {
  type    = string
  default = "ml.m5.xlarge"
}

variable "sagemaker_instance_count" {
  type    = number
  default = 1
}

variable "data_lake_bucket" {
  type        = string
  description = "Existing S3 bucket to use as data lake"
}