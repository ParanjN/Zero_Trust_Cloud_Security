# Main Compliance-as-Code Framework Configuration

module "compliance" {
  source = "./compliance"

  aws_region         = var.aws_region
  project_name       = var.project_name
  environment        = var.environment
  organization_id    = module.aws_organization.organization_id
  log_bucket_arn    = module.aws_organization.log_archive_bucket_arn

  # Enable compliance features
  enable_config           = true
  enable_security_hub    = true
  enable_audit_manager   = true
  enable_pipeline_checks = true

  # Reuse existing organization trail
  cloudtrail_arn = module.aws_organization.cloudtrail_arn

  tags = local.common_tags

  depends_on = [
    module.aws_organization
  ]
}