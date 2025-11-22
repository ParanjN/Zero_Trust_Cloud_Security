# Organization outputs
output "organization_id" {
  value = data.aws_organizations_organization.org.id
}

output "organization_root_id" {
  value = data.aws_organizations_organization.org.roots[0].id
}

# Storage outputs
output "log_archive_bucket" {
  value = var.create_log_bucket ? aws_s3_bucket.log_archive[0].bucket : var.existing_log_bucket_name
}

# Account outputs
output "accounts" {
  value = merge(
    { for k, a in aws_organizations_account.new_accounts : k => a.id },
    { for k, a in aws_organizations_account.existing_accounts : k => a.id }
  )
}

output "new_accounts" {
  value = { for k, a in aws_organizations_account.new_accounts : k => a.id }
  description = "IDs of newly created AWS accounts"
}

output "existing_accounts" {
  value = { for k, a in aws_organizations_account.existing_accounts : k => a.id }  
  description = "IDs of existing managed AWS accounts"
}