variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "create_vpc" {
  description = "Whether to create VPC resources"
  type        = bool
  default     = false
}

variable "vpc_cidrs" {
  type = map(string)
  default = {
    app     = "10.10.0.0/16"
    db      = "10.20.0.0/16"
    logging = "10.30.0.0/16"
  }
}

variable "availability_zones" {
  type = list(string)
  default = []
}

variable "enable_tgw" {
  type    = bool
  default = true
}
