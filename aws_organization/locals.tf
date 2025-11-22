locals {
  # Common tags for all resources
  common_tags = {
    Environment = "management"
    Terraform   = "true"
    Project     = "aws-organization"
  }

  # Organizational unit types
  ou_types = ["security", "logging", "sandbox", "prod", "devtest"]
}