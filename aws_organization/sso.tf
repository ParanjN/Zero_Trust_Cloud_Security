# SSO is enabled at the organization level through the organization resource
# No need for delegated administrator since SSO is managed by the management account

# Get SSO Instance
data "aws_ssoadmin_instances" "sso" {
  depends_on = [
    data.aws_organizations_organization.org
  ]
}

locals {
  # Use coalesce to provide fallback values during initial deployment
  identity_store_id = coalesce(
    try(tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0], null),
    "default-id" # Fallback ID for initial deployment
  )
  sso_instance_arn = coalesce(
    try(tolist(data.aws_ssoadmin_instances.sso.arns)[0], null),
    "arn:aws:sso:::instance/ssoins-default" # Fallback ARN for initial deployment
  )
}

# Add SSO instance ARN and identity store ID to outputs
output "sso_instance_arn" {
  value       = local.sso_instance_arn
  description = "The ARN of the SSO instance"
}

output "identity_store_id" {
  value       = local.identity_store_id
  description = "The ID of the SSO identity store"
}

# Check if SSO is properly configured
resource "null_resource" "check_sso_config" {
  depends_on = [data.aws_ssoadmin_instances.sso]

  triggers = {
    identity_store_id = local.identity_store_id
    sso_instance_arn = local.sso_instance_arn
  }

  lifecycle {
    postcondition {
      condition     = local.identity_store_id != "default-id"
      error_message = "No SSO instances found after enabling the service"
    }
  }
}