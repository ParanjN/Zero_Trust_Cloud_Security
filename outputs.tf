# Organization Outputs
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = module.aws_organization.organization_id
}

output "organization_accounts" {
  description = "Map of created AWS accounts and their IDs"
  value       = module.aws_organization.accounts
}

output "account_users" {
  description = "Account-specific users and their details"
  value       = module.aws_organization.account_users
}

output "account_groups" {
  description = "Account-specific groups"
  value       = module.aws_organization.account_groups
}

output "zero_trust_permission_sets" {
  description = "Zero Trust demo permission sets with different access levels"
  value       = module.aws_organization.zero_trust_permission_sets
}

output "log_archive_bucket" {
  description = "Name of the centralized log archive bucket"
  value       = module.aws_organization.log_archive_bucket
}

# Network Outputs
output "app_vpc_id" {
  description = "ID of the Application VPC"
  value       = module.network.app_vpc_id
}

output "db_vpc_id" {
  description = "ID of the Database VPC"
  value       = module.network.db_vpc_id
}

output "logging_vpc_id" {
  description = "ID of the Logging VPC"
  value       = module.network.logging_vpc_id
}

output "transit_gateway_id" {
  description = "ID of the Transit Gateway (if enabled)"
  value       = module.network.tgw_id
}

output "app_private_subnet_ids" {
  description = "IDs of the Application VPC private subnets"
  value       = module.network.app_private_subnet_ids
}

output "db_private_subnet_ids" {
  description = "IDs of the Database VPC private subnets"
  value       = module.network.db_private_subnet_ids
}

output "logging_private_subnet_ids" {
  description = "IDs of the Logging VPC private subnets"
  value       = module.network.logging_private_subnet_ids
}

# JIT Access Outputs
output "jit_lambda_functions" {
  description = "ARNs of the JIT access Lambda functions"
  value = {
    create = module.jit_access.jit_create_lambda_arn
    cleanup = module.jit_access.jit_cleanup_lambda_arn
  }
}