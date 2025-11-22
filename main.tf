terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.60.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = ">= 2.2.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  # Default tags for all resources
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = var.project_name
    }
  }
}

# AWS Organization Setup Module
module "aws_organization" {
  source = "./aws_organization"

  management_account_profile = var.aws_profile
  management_account_region = var.aws_region
  organization_accounts     = var.organization_accounts
  allowed_regions          = var.allowed_regions
}

# Wait for organization setup to complete
resource "time_sleep" "wait_for_org_setup" {
  depends_on = [module.aws_organization]
  create_duration = "60s"
}

# Network Microsegmentation Module
module "network" {
  source = "./network_microsegmentation"
  depends_on = [time_sleep.wait_for_org_setup]

  # Network configuration
  vpc_cidrs          = var.vpc_cidrs
  aws_region         = var.aws_region
  aws_profile        = var.aws_profile
  availability_zones = var.availability_zones
  enable_tgw         = var.enable_tgw
}

# JIT Access Package Module
module "jit_access" {
  source = "./terraform_jit_package"
  depends_on = [time_sleep.wait_for_org_setup]

  # Required variables for JIT access
  aws_region                    = var.aws_region
  identity_center_instance_arn  = module.aws_organization.sso_instance_arn
  identity_store_id            = module.aws_organization.identity_store_id
}