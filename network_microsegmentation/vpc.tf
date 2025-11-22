# Look up existing VPCs
data "aws_vpcs" "existing" {
  tags = {
    ManagedBy = "Terraform"
  }
}

# Get current VPC limit from Service Quotas
data "aws_servicequotas_service_quota" "vpc_limit" {
  quota_code   = "L-F678F1CE"
  service_code = "vpc"
}

locals {
  # Map of VPC types to their CIDR blocks and names
  vpc_config = {
    app = {
      cidr = var.vpc_cidrs["app"]
      name = "App-VPC"
    }
    db = {
      cidr = var.vpc_cidrs["db"]
      name = "DB-VPC"
    }
    logging = {
      cidr = var.vpc_cidrs["logging"]
      name = "Logging-VPC"
    }
  }

  
  # Calculate available VPC capacity
  current_vpc_count = length(data.aws_vpcs.existing.ids)
  vpc_limit = data.aws_servicequotas_service_quota.vpc_limit.value
  remaining_vpcs = floor(local.vpc_limit - local.current_vpc_count)
  
  # Determine if we can create VPCs - use variable directly
  create_vpcs = var.create_vpc ? 1 : 0
}

# Create VPCs only if we have enough capacity for all of them
resource "aws_vpc" "app" {
  count = local.create_vpcs

  cidr_block = var.vpc_cidrs["app"]
  
  tags = {
    Name = "App-VPC"
    ManagedBy = "Terraform"
  }
}

resource "aws_vpc" "db" {
  count = local.create_vpcs

  cidr_block = var.vpc_cidrs["db"]
  
  tags = {
    Name = "DB-VPC"
    ManagedBy = "Terraform"
  }

  depends_on = [aws_vpc.app]
}

resource "aws_vpc" "logging" {
  count = local.create_vpcs

  cidr_block = var.vpc_cidrs["logging"]
  
  tags = {
    Name = "Logging-VPC"
    ManagedBy = "Terraform"
  }

  depends_on = [aws_vpc.db]
}
