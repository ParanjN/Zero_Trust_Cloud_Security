variable "project_prefix" {
  type        = string
  default     = "risk-compliance"
  description = "Prefix to use for resource naming"
}

variable "quicksight_namespace" {
  type        = string
  default     = "default"
  description = "QuickSight namespace for resource creation"
}

variable "quicksight_user_arn" {
  type        = string
  default     = ""
  description = "ARN of QuickSight user to be used as owner (e.g. arn:aws:quicksight:...:user/default/YourUser)"
}

variable "sagemaker_endpoint_name" {
  type        = string
  default     = ""
  description = "Optional SageMaker endpoint for predictive signals"
}