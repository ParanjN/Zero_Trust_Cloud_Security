# # Terraform: Multi-Account AWS Organizations + SCPs + Org CloudTrail + Log Archive

# This Terraform project automates the following resources in your AWS Organization Management account:

# - Create an AWS Organization (if not present)
# - Create Organizational Units (Security, Logging, Sandbox, Prod, DevTest)
# - Create Member Accounts (Security, Logging, Sandbox, Prod, DevTest)
# - Create Service Control Policies (SCPs) and attach to OUs
# - Create a Log Archive S3 bucket with encryption, versioning, and Object Lock enabled
# - Create an Organization CloudTrail (org-level) that writes to the Log Archive bucket

# Note: Some services (AWS Control Tower, IAM Identity Center/SSO setup, and GuardDuty delegated admin configuration) are not fully supported via Terraform or require extra setup steps. This project includes CLI post-apply steps to finish them.

# ---

# ## File: providers.tf
# ```
# terraform {
#   required_version = ">= 1.2.0"
#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = ">= 4.60.0"
#     }
#   }
# }

# provider "aws" {
#   region  = var.management_account_region
#   profile = var.management_account_profile
# }

# # Note: This Terraform run MUST be executed using credentials for the Organization management (root) account or an IAM role with sufficient Organizations privileges.
# ```

# ---

# ## File: variables.tf
# ```
# variable "management_account_profile" {
#   type    = string
#   default = "default"
# }

# variable "management_account_region" {
#   type    = string
#   default = "us-east-1"
# }

# variable "organization_accounts" {
#   type = map(object({
#     email = string
#     name  = string
#   }))
#   default = {
#     security = { email = "security-admin@example.com", name = "Security" }
#     logging  = { email = "logging-admin@example.com",  name = "Logging" }
#     sandbox  = { email = "sandbox@example.com",      name = "Sandbox" }
#     prod     = { email = "prod-admin@example.com",   name = "Prod" }
#     devtest  = { email = "devtest@example.com",      name = "DevTest" }
#   }
# }

# variable "allowed_regions" {
#   type = list(string)
#   default = ["us-east-1", "us-west-2"]
# }
# ```

# ---

# ## File: main.tf
# ```
# ##########################
# # Organizations
# ##########################
# resource "aws_organizations_organization" "org" {
#   aws_service_access_principals = [
#     "cloudtrail.amazonaws.com",
#     "config.amazonaws.com",
#     "securityhub.amazonaws.com",
#   ]
#   feature_set = "ALL"
# }

# ##########################
# # Organizational Units
# ##########################
# resource "aws_organizations_organizational_unit" "security_ou" {
#   name      = "Security"
#   parent_id = aws_organizations_organization.org.roots[0].id
# }
# resource "aws_organizations_organizational_unit" "logging_ou" {
#   name      = "Logging"
#   parent_id = aws_organizations_organization.org.roots[0].id
# }
# resource "aws_organizations_organizational_unit" "sandbox_ou" {
#   name      = "Sandbox"
#   parent_id = aws_organizations_organization.org.roots[0].id
# }
# resource "aws_organizations_organizational_unit" "prod_ou" {
#   name      = "Prod"
#   parent_id = aws_organizations_organization.org.roots[0].id
# }
# resource "aws_organizations_organizational_unit" "devtest_ou" {
#   name      = "DevTest"
#   parent_id = aws_organizations_organization.org.roots[0].id
# }

# ##########################
# # Accounts
# ##########################
# # Create one aws_organizations_account per entry in variable.organization_accounts
# locals {
#   accounts = var.organization_accounts
# }

# resource "aws_organizations_account" "accounts" {
#   for_each = local.accounts

#   name      = each.value.name
#   email     = each.value.email
#   role_name = "OrganizationAccountAccessRole"

#   # Optional: specify iam_user_access_to_billing
#   iam_user_access_to_billing = "DENY"
# }

# ##########################
# # SCP Policies
# ##########################
# # 1) Deny disabling CloudTrail & GuardDuty
# resource "aws_organizations_policy" "deny_disable_ct_gd" {
#   name        = "DenyDisableCloudTrailGuardDuty"
#   description = "Deny actions that disable CloudTrail or GuardDuty"
#   type        = "SERVICE_CONTROL_POLICY"
#   content     = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid = "DenyCloudTrailGuardDutyDisable",
#         Effect = "Deny",
#         Action = [
#           "cloudtrail:DeleteTrail",
#           "cloudtrail:StopLogging",
#           "guardduty:DeleteDetector",
#           "guardduty:StopMonitoringMembers",
#           "guardduty:DisassociateFromMasterAccount"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# # 2) Deny root actions
# resource "aws_organizations_policy" "deny_root_actions" {
#   name        = "DenyRootActions"
#   description = "Deny actions by the root principal"
#   type        = "SERVICE_CONTROL_POLICY"
#   content     = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid = "DenyRoot",
#         Effect = "Deny",
#         Action = "*",
#         Resource = "*",
#         Condition = {
#           StringLike = {
#             "aws:PrincipalArn" = "arn:aws:iam::*:root"
#           }
#         }
#       }
#     ]
#   })
# }

# # 3) Enforce specific regions (deny other regions)
# resource "aws_organizations_policy" "restrict_regions" {
#   name        = "RestrictRegions"
#   description = "Allow only specified regions"
#   type        = "SERVICE_CONTROL_POLICY"
#   content     = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Sid = "DenyUnsupportedRegions",
#         Effect = "Deny",
#         Action = "*",
#         Resource = "*",
#         Condition = {
#           StringNotEquals = {
#             "aws:RequestedRegion" = var.allowed_regions
#           }
#         }
#       }
#     ]
#   })
# }

# ##########################
# # Attach Policies to Root / OUs
# ##########################
# # Attach deny_disable_ct_gd to root
# resource "aws_organizations_policy_attachment" "attach_deny_disable_ct_gd_root" {
#   policy_id = aws_organizations_policy.deny_disable_ct_gd.id
#   target_id = aws_organizations_organization.org.roots[0].id
# }

# # Attach deny_root_actions to root
# resource "aws_organizations_policy_attachment" "attach_deny_root_root" {
#   policy_id = aws_organizations_policy.deny_root_actions.id
#   target_id = aws_organizations_organization.org.roots[0].id
# }

# # Attach restrict_regions to root
# resource "aws_organizations_policy_attachment" "attach_restrict_regions_root" {
#   policy_id = aws_organizations_policy.restrict_regions.id
#   target_id = aws_organizations_organization.org.roots[0].id
# }

# ##########################
# # Log Archive Bucket (S3) with Object Lock
# ##########################
# resource "aws_s3_bucket" "log_archive" {
#   bucket = "${replace(aws_organizations_organization.org.roots[0].id, ":", "-")}-log-archive-${random_id.bucket_suffix.hex}"

#   acl    = "private"

#   versioning {
#     enabled = true
#   }

#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "aws:kms"
#       }
#     }
#   }

#   object_lock_configuration {
#     object_lock_enabled = "Enabled"
#     rule {
#       default_retention {
#         mode  = "COMPLIANCE"
#         days  = 365
#       }
#     }
#   }

#   lifecycle_rule {
#     id      = "log-archive-life"
#     enabled = true
#     expiration {
#       days = 3650
#     }
#   }

#   tags = {
#     Name = "org-log-archive"
#   }
# }

# resource "random_id" "bucket_suffix" {
#   byte_length = 4
# }

# # KMS key for bucket encryption
# resource "aws_kms_key" "log_bucket_key" {
#   description = "KMS key for log archive bucket"
#   deletion_window_in_days = 30
# }

# resource "aws_kms_alias" "log_bucket_alias" {
#   name          = "alias/log-archive-key"
#   target_key_id = aws_kms_key.log_bucket_key.key_id
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_sse" {
#   bucket = aws_s3_bucket.log_archive.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "aws:kms"
#       kms_master_key_id = aws_kms_key.log_bucket_key.arn
#     }
#   }
# }

# ##########################
# # Organization CloudTrail
# ##########################
# resource "aws_cloudtrail" "org_trail" {
#   name                          = "organization-trail"
#   is_multi_region_trail         = true
#   include_global_service_events = true
#   is_organization_trail         = true
#   s3_bucket_name                = aws_s3_bucket.log_archive.id
#   enable_log_file_validation    = true
#   kms_key_id                    = aws_kms_key.log_bucket_key.arn
# }

# ##########################
# # Outputs
# ##########################
# output "organization_id" {
#   value = aws_organizations_organization.org.id
# }

# output "log_archive_bucket" {
#   value = aws_s3_bucket.log_archive.bucket
# }

# output "accounts" {
#   value = { for k, a in aws_organizations_account.accounts : k => a.id }
# }
# ```

# ---

# ## File: outputs.tf
# ```
# output "organization_root_id" {
#   value = aws_organizations_organization.org.roots[0].id
# }
# ```

# ---

# ## README / Post-Apply Steps
# ```
# # How to run
# 1. Configure AWS CLI/profile for the Organization management account with sufficient privileges.
# 2. terraform init
# 3. terraform plan -var 'management_account_profile=your-profile' -out plan.tfplan
# 4. terraform apply "plan.tfplan"

# # Post-apply manual / CLI steps

# ## 1) AWS Control Tower
# - Control Tower setup cannot be fully automated via Terraform reliably in many environments.
# - Navigate to AWS Console > AWS Control Tower and follow the Landing Zone setup wizard to enable baseline guardrails.

# ## 2) IAM Identity Center (SSO)
# - Configure IAM Identity Center via Console and integrate with your IdP (Okta/Azure AD) or use AWS SSO.
# - Create permission sets and attach to the created accounts.

# ## 3) GuardDuty Org Setup (enable delegated administrator)
# - In the Security account, run:
#   aws guardduty create-detector --enable
# - For organization-wide GuardDuty you may need to enable GuardDuty in the management account and designate a delegated admin account; alternative is to enable in each account or use Security Hub aggregator.

# ## 4) Control Tower / SCP Reconciliation
# - Control Tower may enforce its own guardrails; review attachments and ensure policy precedence is as desired.

# # Notes
# - Object Lock requires the bucket to be created with Object Lock enabled; Terraform config includes object_lock_configuration, but enabling Object Lock on an existing bucket is not supported. Create bucket via Terraform as shown.
# - Emails used for aws_organizations_account must be real and accessible to accept account creation invitations.
# - Some organizations prefer AWS Control Tower account factory for standardized account provisioning; consider using that for production.
