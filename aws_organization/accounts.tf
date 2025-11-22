# Use the organization data source from organization.tf
locals {
  # Map of existing accounts by email
  existing_accounts = {
    for account in data.aws_organizations_organization.org.accounts :
    lower(account.email) => {
      id = account.id
      name = account.name
      email = account.email
    }
  }

  # Map of account configurations to manage
  managed_accounts = {
    for name, config in var.organization_accounts :
    name => merge(config, {
      exists = contains(keys(local.existing_accounts), lower(config.email))
      account_id = try(local.existing_accounts[lower(config.email)].id, null)
    })
  }
}

# Output for account status
output "account_status" {
  value = {
    for name, config in local.managed_accounts :
    name => {
      name = config.name
      email = config.email
      exists = config.exists
      account_id = config.account_id
    }
  }
  description = "Status and details of all managed accounts"
}

# Import statement generator for existing accounts
output "import_statements" {
  value = {
    for name, config in local.managed_accounts :
    name => "terraform import module.aws_organization.aws_organizations_account.existing_accounts[\"${name}\"] ${config.account_id}"
    if config.exists
  }
  description = "Terraform import statements for existing accounts"
}

