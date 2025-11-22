# Resource Pre-check Script
# This script checks for existing AWS resources before Terraform attempts to create them

# Function to write colored output
function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Check-OrganizationResources {
    Write-ColorOutput "Checking AWS Organizations resources..." "Cyan"
    
    # Check Organization
    try {
        $org = aws organizations describe-organization --query 'Organization.Id' --output text
        Write-ColorOutput "✓ Organization exists: $org" "Green"
    }
    catch {
        Write-ColorOutput "× Organization not found" "Yellow"
    }

    # Check OUs
    $ous = @("Security", "Logging", "Sandbox", "Prod", "DevTest")
    Write-ColorOutput "`nChecking Organizational Units:" "Cyan"
    foreach ($ou in $ous) {
        try {
            $ouList = aws organizations list-organizational-units-for-parent --parent-id $(aws organizations list-roots --query 'Roots[0].Id' --output text) --query "OrganizationalUnits[?Name=='$ou'].Name" --output text
            if ($ouList) {
                Write-ColorOutput "✓ OU exists: $ou" "Green"
            } else {
                Write-ColorOutput "× OU not found: $ou" "Yellow"
            }
        }
        catch {
            Write-ColorOutput "× Error checking OU: $ou" "Red"
        }
    }
}

function Check-IAMIdentityCenter {
    Write-ColorOutput "`nChecking IAM Identity Center (SSO)..." "Cyan"
    
    try {
        $sso = aws sso-admin list-instances --query 'Instances[0].InstanceArn' --output text
        if ($sso -and $sso -ne "None") {
            Write-ColorOutput "✓ SSO is enabled" "Green"
            
            # Check Permission Sets
            Write-ColorOutput "`nChecking Permission Sets:" "Cyan"
            $permissionSets = @("ReadOnly", "DevOps", "Admin")
            foreach ($ps in $permissionSets) {
                $exists = aws sso-admin list-permission-sets --instance-arn $sso --query "PermissionSets[*]" --output text
                if ($exists) {
                    Write-ColorOutput "✓ Permission Set exists: $ps" "Green"
                } else {
                    Write-ColorOutput "× Permission Set not found: $ps" "Yellow"
                }
            }
        } else {
            Write-ColorOutput "× SSO is not enabled" "Yellow"
        }
    }
    catch {
        Write-ColorOutput "× Error checking SSO status" "Red"
    }
}

function Check-NetworkResources {
    Write-ColorOutput "`nChecking Network Resources..." "Cyan"
    
    # Check VPCs
    try {
        $vpcs = aws ec2 describe-vpcs --query 'Vpcs[*].VpcId' --output text
        $vpcCount = ($vpcs -split '\s+').Count
        Write-ColorOutput "Found $vpcCount VPCs" "Green"
        
        if ($vpcCount -ge 5) {
            Write-ColorOutput "! Warning: VPC limit may be reached (default limit is 5)" "Yellow"
        }
    }
    catch {
        Write-ColorOutput "× Error checking VPCs" "Red"
    }

    # Check Transit Gateway
    try {
        $tgw = aws ec2 describe-transit-gateways --query 'TransitGateways[0].TransitGatewayId' --output text
        if ($tgw -and $tgw -ne "None") {
            Write-ColorOutput "✓ Transit Gateway exists: $tgw" "Green"
        } else {
            Write-ColorOutput "× Transit Gateway not found" "Yellow"
        }
    }
    catch {
        Write-ColorOutput "× Error checking Transit Gateway" "Red"
    }
}

function Check-S3AndCloudTrail {
    Write-ColorOutput "`nChecking S3 and CloudTrail Resources..." "Cyan"
    
    # Check KMS Key
    try {
        $kms = aws kms list-aliases --query "Aliases[?AliasName=='alias/log-archive-key'].AliasArn" --output text
        if ($kms) {
            Write-ColorOutput "✓ KMS key exists for log archive" "Green"
        } else {
            Write-ColorOutput "× KMS key not found" "Yellow"
        }
    }
    catch {
        Write-ColorOutput "× Error checking KMS key" "Red"
    }

    # Check CloudTrail
    try {
        $trail = aws cloudtrail list-trails --query "Trails[?Name=='organization-trail'].Name" --output text
        if ($trail) {
            Write-ColorOutput "✓ Organization CloudTrail exists" "Green"
        } else {
            Write-ColorOutput "× Organization CloudTrail not found" "Yellow"
        }
    }
    catch {
        Write-ColorOutput "× Error checking CloudTrail" "Red"
    }
}

function Check-IAMRoles {
    Write-ColorOutput "`nChecking IAM Roles..." "Cyan"
    
    # Check Lambda execution role
    try {
        $role = aws iam get-role --role-name "jit-access-lambda-role" --query 'Role.RoleName' --output text
        if ($role) {
            Write-ColorOutput "✓ Lambda execution role exists" "Green"
        }
    }
    catch {
        Write-ColorOutput "× Lambda execution role not found" "Yellow"
    }
}

# Main execution
Write-ColorOutput "Starting pre-deployment resource check..." "White"
Write-ColorOutput "=======================================" "White"

Check-OrganizationResources
Check-IAMIdentityCenter
Check-NetworkResources
Check-S3AndCloudTrail
Check-IAMRoles

Write-ColorOutput "`nResource check complete!" "White"
Write-ColorOutput "=======================================" "White"