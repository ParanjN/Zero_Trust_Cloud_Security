# Enable GuardDuty in this account (per-account). For organization-wide, use delegated admin flow via CLI/console.
resource "aws_guardduty_detector" "detector" {
  enable = true
}

# Security Hub enablement
resource "aws_securityhub_account" "hub" {}

# Enable CIS standard (example)
resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}
