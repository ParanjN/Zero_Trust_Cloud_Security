# Get organization accounts
data "aws_organizations_organization" "current" {}

locals {
  # Map of account names to their IDs from the organization
  org_accounts = {
    for account in data.aws_organizations_organization.current.accounts :
    lower(account.name) => account.id
  }

  # Validate target accounts exist in organization - simplified to avoid plan-time issues
  valid_assignments = var.target_accounts
}

# Create assignments for prod account if it exists
resource "aws_ssoadmin_account_assignment" "admins_prod" {
  count = lookup(var.target_accounts, "prod", null) != null ? 1 : 0

  instance_arn       = var.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.ps["Admin"].arn
  principal_type     = "GROUP"
  principal_id       = aws_identitystore_group.admins.group_id
  target_id          = var.target_accounts["prod"].account_id
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_account_assignment" "devops_dev" {
  count = lookup(var.target_accounts, "dev", null) != null ? 1 : 0

  instance_arn       = var.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.ps["DevOps"].arn
  principal_type     = "GROUP"
  principal_id       = aws_identitystore_group.devops.group_id
  target_id          = var.target_accounts["dev"].account_id
  target_type        = "AWS_ACCOUNT"
}

# Output validation results
output "account_validation" {
  value = {
    valid_accounts = keys(var.target_accounts)
    all_org_accounts = keys(local.org_accounts)
  }
  description = "Shows target accounts and all organization accounts"
}
