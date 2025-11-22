# Security Hub Configuration

# Enable Security Hub
resource "aws_securityhub_account" "main" {}

# Enable Security Standards
resource "aws_securityhub_standards_subscription" "cis_aws" {
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/cis-aws-foundations-benchmark/v/1.2.0"
}

resource "aws_securityhub_standards_subscription" "pci_dss" {
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/pci-dss/v/3.2.1"
}

resource "aws_securityhub_standards_subscription" "nist_800_53" {
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/nist-800-53/v/5.0.0"
}

# Aggregate findings from AWS Config
resource "aws_securityhub_finding_aggregator" "organization" {
  linking_mode = "ALL_REGIONS"
  depends_on   = [aws_securityhub_account.main]
}