# Create new accounts that don't exist yet
resource "aws_organizations_account" "new_accounts" {
  for_each = {
    for name, config in local.managed_accounts :
    name => config
    if !config.exists
  }

  name      = each.value.name
  email     = each.value.email
  parent_id = local.all_ous[lower(each.value.ou_name)]
  role_name = "OrganizationAccountAccessRole"

  tags = {
    ManagedBy = "Terraform"
    Purpose   = each.value.ou_name
  }

  depends_on = [
    aws_organizations_organizational_unit.ou,
    data.aws_organizations_organization.org
  ]
}

# Manage existing accounts (import these if needed)
resource "aws_organizations_account" "existing_accounts" {
  for_each = {
    for name, config in local.managed_accounts :
    name => config
    if config.exists && config.account_id != null
  }

  name      = each.value.name
  email     = each.value.email
  parent_id = local.all_ous[lower(each.value.ou_name)]
  role_name = "OrganizationAccountAccessRole"

  tags = {
    ManagedBy = "Terraform"
    AccountId = each.value.account_id
  }

  depends_on = [
    aws_organizations_organizational_unit.ou,
    data.aws_organizations_organization.org
  ]

  lifecycle {
    ignore_changes = [
      name,
      email,
      role_name,
      iam_user_access_to_billing
    ]
    prevent_destroy = true
  }
}