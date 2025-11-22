# Network Micro-Segmentation Terraform Module

This Terraform package provisions a simple micro-segmentation lab:
- App VPC, DB VPC, Logging VPC
- Private subnets per AZ (or single subnet if AZ list empty)
- Network ACL example for App VPC
- Transit Gateway attachments (hub-and-spoke)
- VPC endpoints (S3 gateway, DynamoDB interface example)
- Security groups for App and DB isolation

## Usage

1. Customize `variables.tf` or pass -var flags:
   - aws_region
   - aws_profile
   - availability_zones (optional list)
   - vpc_cidrs (optional map to change CIDRs)

2. Initialize and apply:
```bash
terraform init
terraform apply -var 'aws_profile=your-profile' -var 'aws_region=us-east-1'
```

## Notes & Next Steps
- TGW attachments create one attachment per VPC using the first private subnet created.
- Update route tables to control TGW routing and enforce one-way logging if desired.
- For production, add NAT gateways for private subnets, and hardened NACL rules.
