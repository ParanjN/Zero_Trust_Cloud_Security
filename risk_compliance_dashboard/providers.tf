# Random suffix for unique resource naming
resource "random_id" "suffix" {
  byte_length = 3
}

# Get current AWS account identity and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}