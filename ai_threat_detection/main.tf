# ============================================================
# AI-Driven Threat Detection Infrastructure - Main Module
# ============================================================

module "ai_threat_detection" {
  source = "./ai_threat_detection"

  # General Configuration
  aws_region = var.aws_region
  project    = var.project

  # SageMaker Configuration
  sagemaker_rcf_image     = var.sagemaker_rcf_image
  sagemaker_instance_type = var.sagemaker_instance_type
  sagemaker_instance_count = var.sagemaker_instance_count

  # Reuse existing S3 bucket from aws_organization module
  data_lake_bucket = module.aws_organization.log_archive_bucket

  # Dependencies
  depends_on = [module.aws_organization]
}