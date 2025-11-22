module "risk_compliance_dashboard" {
  source = "./risk_compliance_dashboard"

  project_prefix          = var.resource_prefix
  quicksight_namespace   = var.quicksight_namespace
  quicksight_user_arn    = var.quicksight_user_arn
  sagemaker_endpoint_name = var.sagemaker_endpoint_name
}