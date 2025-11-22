# Get existing organization
data "aws_organizations_organization" "org" {}

# Outputs for OU IDs
output "security_ou_id" {
  value = local.all_ous["security"]
  description = "ID of the Security OU"
}

output "logging_ou_id" {
  value = local.all_ous["logging"]
  description = "ID of the Logging OU"
}

output "sandbox_ou_id" {
  value = local.all_ous["sandbox"]
  description = "ID of the Sandbox OU"
}

output "prod_ou_id" {
  value = local.all_ous["prod"]
  description = "ID of the Production OU"
}

output "devtest_ou_id" {
  value = local.all_ous["devtest"]
  description = "ID of the Dev/Test OU"
}

# Output the complete OU mapping for reference
output "organizational_units" {
  value = local.all_ous
  description = "Map of all organizational unit names to their IDs"
}