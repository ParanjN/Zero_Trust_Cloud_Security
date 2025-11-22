# ============================================================
# Forensics & Incident Simulation Lab - Main Configuration
# ============================================================

locals {
  common_tags = {
    Environment = "forensics-lab"
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

module "forensics_lab" {
  source = "./forensics_lab"

  aws_region     = var.aws_region
  project_name   = var.project_name
  environment    = "forensics-lab"

  # VPC Configuration
  vpc_cidr             = "10.100.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  
  # Workload Configuration
  instance_type_linux   = "t3.medium"
  instance_type_windows = "t3.large"
  rds_instance_class    = "db.t3.medium"
  eks_node_type         = "t3.medium"

  # Existing Components
  log_bucket_arn        = module.aws_organization.log_archive_bucket_arn
  cloudtrail_arn        = module.aws_organization.cloudtrail_arn
  guardduty_detector_id = module.security.guardduty_detector_id

  tags = local.common_tags

  depends_on = [
    module.aws_organization,
    module.security
  ]
}