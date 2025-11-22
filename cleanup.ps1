# Terraform destroy script for all resources
# To run this script, you need to:
#
# Option 1: Run PowerShell as Administrator and execute:
#   Set-ExecutionPolicy RemoteSigned
#
# Option 2: Run the script directly with bypass:
#   powershell -ExecutionPolicy Bypass -File cleanup.ps1
#
# Option 3: For current PowerShell session only:
#   Set-ExecutionPolicy Bypass -Scope Process

Write-Host "Starting cleanup of all AWS resources..." -ForegroundColor Yellow

# Function to run terraform destroy with error handling
function Invoke-TerraformDestroy {
    param (
        [string]$target,
        [string]$resourceName
    )
    
    try {
        Write-Host "Attempting to destroy $resourceName..." -ForegroundColor Yellow
        $result = terraform destroy -target="$target" -auto-approve 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Successfully destroyed $resourceName" -ForegroundColor Green
        } else {
            if ($result -match "Resource not found" -or 
                $result -match "No such resource exists" -or 
                $result -match "Cannot delete" -or
                $result -match "not a member of an organization" -or
                $result -match "EMAIL_ALREADY_EXISTS" -or
                $result -match "IdentityStore not present" -or
                $result -match "does not allow ACLs") {
                Write-Host "Resource $resourceName not found or already deleted" -ForegroundColor Yellow
            } else {
                Write-Host "Warning: Issue destroying $resourceName. Continuing..." -ForegroundColor Yellow
                Write-Host $result -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "Error occurred while destroying $resourceName. Continuing..." -ForegroundColor Yellow
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }
}

# Function to check AWS Organizations status
function Test-AWSOrganization {
    try {
        $orgStatus = aws organizations describe-organization 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "AWS Organizations is enabled" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "AWS Organizations is not enabled" -ForegroundColor Yellow
        Write-Host "Please enable AWS Organizations first in the AWS Console" -ForegroundColor Yellow
        return $false
    }
}

# Function to check IAM Identity Center status
function Test-IAMIdentityCenter {
    try {
        $ssoStatus = aws sso-admin list-instances 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "IAM Identity Center is enabled" -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "IAM Identity Center is not enabled" -ForegroundColor Yellow
        Write-Host "Please enable IAM Identity Center first in the AWS Console" -ForegroundColor Yellow
        return $false
    }
}

# First, remove any local Terraform state locks if they exist
if (Test-Path .terraform.lock.hcl) {
    Remove-Item .terraform.lock.hcl -Force
    Write-Host "Removed Terraform lock file" -ForegroundColor Green
}

# Initialize Terraform
Write-Host "`nInitializing Terraform..." -ForegroundColor Yellow
terraform init

# Set error action preference to continue
$ErrorActionPreference = "Continue"

# Check AWS Organizations and IAM Identity Center status
Write-Host "`nChecking AWS service prerequisites..." -ForegroundColor Yellow
$orgEnabled = Test-AWSOrganization
$ssoEnabled = Test-IAMIdentityCenter

if (-not $orgEnabled -or -not $ssoEnabled) {
    Write-Host "`nWarning: Some prerequisites are not met. The cleanup might encounter errors." -ForegroundColor Yellow
    Write-Host "Would you like to continue anyway? (Y/N)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -ne "Y") {
        Write-Host "Cleanup cancelled" -ForegroundColor Red
        exit
    }
}

Write-Host "`nStarting resource cleanup..." -ForegroundColor Yellow

# Create a destroy order to handle dependencies
$resourceGroups = @(
    "JIT Access Resources",
    "Network Resources",
    "Organization Resources"
)

foreach ($group in $resourceGroups) {
    Write-Host "`nDestroying $group..." -ForegroundColor Yellow
    
    switch ($group) {
        "JIT Access Resources" {
            # First remove assignments and permission sets
            Invoke-TerraformDestroy "module.jit_access.aws_ssoadmin_account_assignment.assignments" "SSO Account Assignments"
            Invoke-TerraformDestroy "module.jit_access.aws_ssoadmin_permission_set.ps" "SSO Permission Sets"
            
            # Remove IAM Identity Store users and groups
            Invoke-TerraformDestroy "module.jit_access.aws_identitystore_user.alice" "Identity Store User: Alice"
            Invoke-TerraformDestroy "module.jit_access.aws_identitystore_user.bob" "Identity Store User: Bob"
            Invoke-TerraformDestroy "module.jit_access.aws_identitystore_group.admins" "Identity Store Group: Admins"
            Invoke-TerraformDestroy "module.jit_access.aws_identitystore_group.devops" "Identity Store Group: DevOps"
            
            # Remove Lambda functions and related resources
            Invoke-TerraformDestroy "module.jit_access.aws_lambda_function.jit_create" "Lambda: JIT Create"
            Invoke-TerraformDestroy "module.jit_access.aws_lambda_function.jit_cleanup" "Lambda: JIT Cleanup"
            Invoke-TerraformDestroy "module.jit_access.aws_iam_role.lambda_role" "Lambda IAM Role"
        }
        
        "Network Resources" {
            # First remove Transit Gateway attachments
            Invoke-TerraformDestroy "module.network.aws_ec2_transit_gateway_vpc_attachment.app_attach" "TGW App Attachment"
            Invoke-TerraformDestroy "module.network.aws_ec2_transit_gateway_vpc_attachment.db_attach" "TGW DB Attachment"
            Invoke-TerraformDestroy "module.network.aws_ec2_transit_gateway_vpc_attachment.logging_attach" "TGW Logging Attachment"
            
            # Remove Transit Gateway
            Invoke-TerraformDestroy "module.network.aws_ec2_transit_gateway.tgw" "Transit Gateway"
            
            # Remove security groups
            Invoke-TerraformDestroy "module.network.aws_security_group_rule.db_from_app" "Security Group Rule: DB from App"
            Invoke-TerraformDestroy "module.network.aws_security_group.app_sg" "Security Group: App"
            Invoke-TerraformDestroy "module.network.aws_security_group.db_sg" "Security Group: DB"
            Invoke-TerraformDestroy "module.network.aws_security_group.logging_sg" "Security Group: Logging"
            
            # Remove subnets
            Invoke-TerraformDestroy "module.network.aws_subnet.app_private" "Subnet: App Private"
            Invoke-TerraformDestroy "module.network.aws_subnet.db_private" "Subnet: DB Private"
            Invoke-TerraformDestroy "module.network.aws_subnet.logging_private" "Subnet: Logging Private"
            
            # Remove VPCs
            Invoke-TerraformDestroy "module.network.aws_vpc.app" "VPC: App"
            Invoke-TerraformDestroy "module.network.aws_vpc.db" "VPC: DB"
            Invoke-TerraformDestroy "module.network.aws_vpc.logging" "VPC: Logging"
        }
        
        "Organization Resources" {
            # First remove CloudTrail
            Invoke-TerraformDestroy "module.aws_organization.aws_cloudtrail.org_trail" "CloudTrail"
            
            # Remove S3 bucket configurations
            Invoke-TerraformDestroy "module.aws_organization.aws_s3_bucket_policy.log_archive" "S3 Bucket Policy"
            Invoke-TerraformDestroy "module.aws_organization.aws_s3_bucket_acl.log_archive" "S3 Bucket ACL"
            Invoke-TerraformDestroy "module.aws_organization.aws_s3_bucket_ownership_controls.log_archive" "S3 Bucket Ownership Controls"
            Invoke-TerraformDestroy "module.aws_organization.aws_s3_bucket_versioning.log_archive" "S3 Bucket Versioning"
            Invoke-TerraformDestroy "module.aws_organization.aws_s3_bucket_object_lock_configuration.log_archive" "S3 Bucket Object Lock"
            Invoke-TerraformDestroy "module.aws_organization.aws_s3_bucket.log_archive" "S3 Bucket"
            
            # Remove Organization policies
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_policy_attachment.attach_deny_disable_ct_gd_root" "Policy Attachment: Deny Disable CT/GD"
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_policy_attachment.attach_deny_root_root" "Policy Attachment: Deny Root"
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_policy_attachment.attach_restrict_regions_root" "Policy Attachment: Restrict Regions"
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_policy.deny_disable_ct_gd" "Policy: Deny Disable CT/GD"
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_policy.deny_root_actions" "Policy: Deny Root Actions"
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_policy.restrict_regions" "Policy: Restrict Regions"
            
            # Remove Organization accounts
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_account.accounts" "Organization Accounts"
            
            # Remove Organization OUs
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_organizational_unit.security_ou" "OU: Security"
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_organizational_unit.logging_ou" "OU: Logging"
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_organizational_unit.sandbox_ou" "OU: Sandbox"
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_organizational_unit.prod_ou" "OU: Prod"
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_organizational_unit.devtest_ou" "OU: DevTest"
            
            # Finally remove the organization itself
            Invoke-TerraformDestroy "module.aws_organization.aws_organizations_organization.org" "AWS Organization"
        }
    }
    Write-Host "Completed destroying $group" -ForegroundColor Green
}

# Final cleanup of any remaining resources
Write-Host "`nPerforming final cleanup of any remaining resources..." -ForegroundColor Yellow
try {
    terraform destroy -auto-approve
} catch {
    Write-Host "Warning: Issues during final cleanup. Some resources might need manual verification." -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

# Clean up Terraform files
Write-Host "`nCleaning up Terraform files..." -ForegroundColor Yellow
$filesToClean = @(".terraform", "terraform.tfstate", "terraform.tfstate.backup")
foreach ($file in $filesToClean) {
    try {
        if (Test-Path $file) {
            if ((Get-Item $file) -is [System.IO.DirectoryInfo]) {
                Remove-Item $file -Recurse -Force
            } else {
                Remove-Item $file -Force
            }
            Write-Host "Removed $file" -ForegroundColor Green
        }
    } catch {
        Write-Host "Warning: Could not remove $file" -ForegroundColor Yellow
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }
}

Write-Host "`nCleanup complete!" -ForegroundColor Green
Write-Host "Note: Some resources might need manual verification in the AWS Console:" -ForegroundColor Yellow
Write-Host "1. Check AWS Organizations in the AWS Console" -ForegroundColor Yellow
Write-Host "2. Verify IAM Identity Center (SSO) settings" -ForegroundColor Yellow
Write-Host "3. Check S3 buckets for any remaining content" -ForegroundColor Yellow
Write-Host "4. Verify that all AWS accounts have been removed" -ForegroundColor Yellow
Write-Host "5. Check CloudTrail for any remaining trails" -ForegroundColor Yellow
Write-Host "6. Verify that all VPCs and their resources are cleaned up" -ForegroundColor Yellow

Write-Host "`nCommon cleanup steps if resources remain:" -ForegroundColor Cyan
Write-Host "1. AWS Organizations: Manually remove member accounts first" -ForegroundColor Cyan
Write-Host "2. S3 Buckets: Empty buckets before deletion" -ForegroundColor Cyan
Write-Host "3. VPCs: Remove dependencies (endpoints, gateways) first" -ForegroundColor Cyan
Write-Host "4. IAM Identity Center: Remove assignments before users/groups" -ForegroundColor Cyan