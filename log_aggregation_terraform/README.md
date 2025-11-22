Log Aggregation Terraform Package (CloudTrail, VPC Flow Logs, GuardDuty, Security Hub, Firehose -> OpenSearch)

Overview
--------
This package provisions core log aggregation components for a single account (or management account when creating org CloudTrail):
- KMS key for encryption
- Central S3 log bucket (with Object Lock configuration)
- Forensics S3 bucket (Object Lock)
- Organization CloudTrail (create in management account)
- VPC Flow Logs (for provided VPC IDs)
- OpenSearch domain for SIEM
- Kinesis Firehose delivery stream to OpenSearch (with S3 backup)
- GuardDuty detector and Security Hub enablement (per-account)

Important notes
---------------
- Run from the AWS Organization management account to create Organization CloudTrail. CloudTrail org creation requires management account privileges.
- Object Lock must be enabled at bucket creation; do not remove object_lock_configuration later.
- For organization-wide GuardDuty/Security Hub you may need to designate delegated admin via AWS CLI, e.g.:

  aws guardduty create-organization-admin-account --admin-account-id <account-id>

- Adjust var.vpc_ids to include the VPCs you want flow logs for (or extend to discover VPCs dynamically).

Usage
-----
1. Update terraform.tfvars or pass -var values for aws_profile, aws_region, log_bucket_name, forensics_bucket_name, vpc_ids.
2. terraform init
3. terraform plan -out plan.tf
4. terraform apply "plan.tf"

Next steps (recommended)
------------------------
- Add a Lambda processor on Firehose to parse CloudTrail into structured documents for OpenSearch.
- Secure OpenSearch access with fine-grained access control (Cognito or IAM policies).
- Automate GuardDuty org setup and Security Hub aggregation if deploying to multiple accounts.
