variable "management_account_profile" {
  type    = string
  default = "default"
}

variable "management_account_region" {
  type    = string
  default = "us-east-1"
}

variable "organization_accounts" {
  type = map(object({
    email   = string
    name    = string
    ou_name = string
  }))
  default = {
    security = { email = "nachiketparanjape123+security@gmail.com", name = "Security", ou_name = "security" }
    logging  = { email = "nachiketparanjape123+logging@gmail.com",  name = "Logging",  ou_name = "logging" }
    sandbox  = { email = "nachiketparanjape123+sandbox@gmail.com",  name = "Sandbox",  ou_name = "sandbox" }
    prod     = { email = "nachiketparanjape123+prod@gmail.com",     name = "Prod",     ou_name = "prod" }
    devtest  = { email = "nachiketparanjape123+devtest@gmail.com", name = "DevTest", ou_name = "devtest" }
  }
}

variable "allowed_regions" {
  type = list(string)
  default = ["us-east-1", "us-west-2"]
}

# Resource creation flags
variable "create_vpc" {
  description = "Whether to create VPCs"
  type        = bool
  default     = true
}

variable "create_tgw" {
  description = "Whether to create Transit Gateway"
  type        = bool
  default     = true
}

variable "create_sso_permission_sets" {
  description = "Whether to create SSO permission sets"
  type        = bool
  default     = true
}

variable "create_cloudtrail" {
  description = "Whether to create CloudTrail"
  type        = bool
  default     = true
}

variable "create_log_bucket" {
  description = "Whether to create log archive bucket"
  type        = bool
  default     = true
}

# Existing resource references
variable "existing_vpc_ids" {
  description = "Map of existing VPC IDs to use"
  type        = map(string)
  default     = {}
}

variable "existing_tgw_id" {
  description = "ID of existing Transit Gateway to use"
  type        = string
  default     = null
}

variable "existing_cloudtrail_name" {
  description = "Name of existing CloudTrail to use"
  type        = string
  default     = null
}

variable "existing_log_bucket_name" {
  description = "Name of existing log archive bucket to use"
  type        = string
  default     = null
}

variable "existing_permission_set_arns" {
  description = "Map of existing SSO permission set ARNs"
  type        = map(string)
  default     = {}
}

variable "existing_kms_key_id" {
  description = "ID of existing KMS key for CloudTrail logs and bucket encryption"
  type        = string
  default     = null
}