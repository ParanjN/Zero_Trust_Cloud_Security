variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "identity_center_instance_arn" {
  description = "IAM Identity Center instance ARN. (Enable SSO in console first)"
  type        = string
}

variable "identity_store_id" {
  description = "Identity Store ID for the built-in identity store."
  type        = string
}

variable "target_accounts" {
  type = map(object({ account_id = string }))
  default = {
    dev  = { account_id = "111111111111" }
    prod = { account_id = "222222222222" }
  }
}

variable "jit_default_ttl_minutes" {
  type    = number
  default = 60
}
