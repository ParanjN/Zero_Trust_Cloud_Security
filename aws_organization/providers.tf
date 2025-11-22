terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.60.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.0"
    }
  }
}

provider "aws" {
  region  = var.management_account_region
  profile = var.management_account_profile
}

# Note: This Terraform run MUST be executed using credentials for the Organization management (root) account or an IAM role with sufficient Organizations privileges.