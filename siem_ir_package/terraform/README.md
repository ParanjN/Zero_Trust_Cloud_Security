SIEM Dashboards & Automated IR Terraform Package (skeleton)

This package provisions:
- Forensic S3 bucket (Object Lock)
- KMS key for forensic bucket
- Lambda playbooks for isolate EC2, lockdown S3, revoke IAM (packaged and created)
- EventBridge rules to trigger Lambdas for GuardDuty findings, S3 object events, and IAM key events
- Instructions for importing OpenSearch Dashboards saved objects (provided in opensearch_dashboards/)

Notes:
- Provide OpenSearch Dashboards endpoint variable to connect and import assets manually or via API
- Ensure the account has GuardDuty enabled and CloudTrail configured to emit events (CloudTrail required for CloudWatch Events on S3/IAM)
- Lambda code is simplistic and intended for lab/testing — review and harden for production
