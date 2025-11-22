# General Configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to use for naming resources"
  type        = string
  default     = "aws-security"
}

# QuickSight Configuration
variable "quicksight_namespace" {
  description = "QuickSight namespace for dashboard resources"
  type        = string
  default     = "default"
}

variable "quicksight_user_arn" {
  description = "ARN of QuickSight user to be used as owner"
  type        = string
  default     = ""
}

# Network Configuration
variable "create_vpc" {
  description = "Whether to create VPC resources"
  type        = bool
  default     = false
}

# Optional SageMaker Configuration
variable "sagemaker_endpoint_name" {
  description = "Optional SageMaker endpoint for predictive risk signals"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment name (e.g., prod, dev, staging)"
  type        = string
  default     = "prod"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "AWS-Organization-Setup"
}

# Organization Variables

# Identity Store Variables
variable "alice_email" {
  description = "Email address for Alice user"
  type        = string
  default     = "alice@example.com"
}

variable "bob_email" {
  description = "Email address for Bob user"
  type        = string
  default     = "bob@example.com"
}
variable "organization_accounts" {
  description = "Map of AWS accounts to be created in the organization"
  type = map(object({
    email   = string
    name    = string
    ou_name = string
  }))
  default = {
    security = { email = "nachiketparanjape123+security@gmail.com", name = "Security", ou_name = "security" }
    logging  = { email = "nachiketparanjape123+logging@gmail.com", name = "Logging",  ou_name = "logging" }
    sandbox  = { email = "nachiketparanjape123+sandbox@gmail.com", name = "Sandbox",  ou_name = "sandbox" }
    prod     = { email = "nachiketparanjape123+prod@gmail.com", name = "Prod",     ou_name = "prod" }
    devtest  = { email = "nachiketparanjape123+devtest@gmail.com", name = "DevTest",  ou_name = "devtest" }
}
}

variable "allowed_regions" {
  description = "List of allowed AWS regions"
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

# Network Variables
variable "vpc_cidrs" {
  description = "Map of CIDR blocks for VPCs"
  type        = map(string)
  default = {
    app     = "10.10.0.0/16"
    db      = "10.20.0.0/16"
    logging = "10.30.0.0/16"
  }
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = []
}

variable "enable_tgw" {
  description = "Enable Transit Gateway"
  type        = bool
  default     = true
}

# JIT Access Configuration
variable "identity_center_instance_arn" {
  description = "ARN of the AWS IAM Identity Center instance"
  type        = string
}

variable "identity_store_id" {
  description = "ID of the AWS IAM Identity Store"
  type        = string
}