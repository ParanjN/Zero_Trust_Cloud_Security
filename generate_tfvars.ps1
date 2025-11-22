# Check for existing resources and generate tfvars
param(
    [string]$OutputFile = "existing_resources.auto.tfvars"
)

function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Initialize tfvars content
$tfvars = [System.Collections.ArrayList]@()

try {
    # Check for existing S3 bucket
    Write-ColorOutput "Checking for existing log archive bucket..." "Cyan"
    try {
        $logBuckets = aws s3api list-buckets --query 'Buckets[?contains(Name, `-log-archive-`)].Name' --output text 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "AWS CLI command failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-ColorOutput "Error checking S3 buckets: $_" "Red"
        $logBuckets = $null
    }
    if ($logBuckets -and $logBuckets -ne "None") {
        $bucketName = $logBuckets.Split()[0]  # Take the first bucket if multiple exist
        [void]$tfvars.Add("create_log_bucket = false")
        [void]$tfvars.Add("existing_log_bucket_name = `"$bucketName`"")
        Write-ColorOutput " Found existing log bucket: $bucketName" "Green"
    } else {
        [void]$tfvars.Add("create_log_bucket = true")
        Write-ColorOutput " No existing log bucket found" "Yellow"
    }

    # Check for existing CloudTrail
    Write-ColorOutput "`nChecking for existing CloudTrail..." "Cyan"
    try {
        $trail = aws cloudtrail list-trails --query 'Trails[?Name==`organization-trail`].Name' --output text
    } catch {
        Write-ColorOutput "Error checking CloudTrail: $_" "Red"
        $trail = $null
    }
    if ($trail -and $trail -ne "None") {
        [void]$tfvars.Add("create_cloudtrail = false")
        [void]$tfvars.Add("existing_cloudtrail_name = `"$trail`"")
        Write-ColorOutput " Found existing CloudTrail: $trail" "Green"
    } else {
        [void]$tfvars.Add("create_cloudtrail = true")
        Write-ColorOutput " No existing CloudTrail found" "Yellow"
    }

    # Check for existing VPCs
    Write-ColorOutput "`nChecking for existing VPCs..." "Cyan"
    try {
        $vpcs = aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value | [0]]' --output text
    } catch {
        Write-ColorOutput "Error checking VPCs: $_" "Red"
        $vpcs = $null
    }
    if ($vpcs -and $vpcs -ne "None") {
        $vpcMap = @{}
        $vpcs -split "`n" | ForEach-Object {
            $vpcId, $name = $_ -split "`t"
            if ($name -match "(app|logging|db)") {
                $vpcMap[$name] = $vpcId
            }
        }
        
        if ($vpcMap.Count -gt 0) {
            [void]$tfvars.Add("create_vpc = false")
            [void]$tfvars.Add("existing_vpc_ids = {")
            foreach ($entry in $vpcMap.GetEnumerator()) {
                [void]$tfvars.Add("    $($entry.Key) = `"$($entry.Value)`"")
            }
            [void]$tfvars.Add("}")
            Write-ColorOutput " Found existing VPCs: $($vpcMap.Count)" "Green"
        } else {
            [void]$tfvars.Add("create_vpc = true")
            Write-ColorOutput " No matching VPCs found" "Yellow"
        }
    } else {
        [void]$tfvars.Add("create_vpc = true")
        Write-ColorOutput " No VPCs found" "Yellow"
    }

    # Check for existing Transit Gateway
    Write-ColorOutput "`nChecking for existing Transit Gateway..." "Cyan"
    try {
        $tgw = aws ec2 describe-transit-gateways --query "TransitGateways[0].TransitGatewayId" --output text
    } catch {
        Write-ColorOutput "Error checking Transit Gateway: $_" "Red"
        $tgw = $null
    }
    if ($tgw -and $tgw -ne "None") {
        [void]$tfvars.Add("create_tgw = false")
        [void]$tfvars.Add("existing_tgw_id = `"$tgw`"")
        Write-ColorOutput " Found existing Transit Gateway: $tgw" "Green"
    } else {
        [void]$tfvars.Add("create_tgw = true")
        Write-ColorOutput " No existing Transit Gateway found" "Yellow"
    }

    # Check for existing SSO Permission Sets
    Write-ColorOutput "`nChecking for existing SSO Permission Sets..." "Cyan"
    try {
        $ssoInstance = aws sso-admin list-instances --query "Instances[0].InstanceArn" --output text
    } catch {
        Write-ColorOutput "Error checking SSO instances: $_" "Red"
        $ssoInstance = $null
    }
    if ($ssoInstance -and $ssoInstance -ne "None") {
        try {
            $permissionSets = aws sso-admin list-permission-sets --instance-arn $ssoInstance --query "PermissionSets[*]" --output text
        } catch {
            Write-ColorOutput "Error checking Permission Sets: $_" "Red"
            $permissionSets = $null
        }
        if ($permissionSets) {
            [void]$tfvars.Add("create_sso_permission_sets = false")
            [void]$tfvars.Add("existing_permission_set_arns = {")
            $permissionSets -split "`n" | ForEach-Object {
                if ($_) {
                    [void]$tfvars.Add("    `"$_`" = `"$_`"")
                }
            }
            [void]$tfvars.Add("}")
            Write-ColorOutput " Found existing Permission Sets" "Green"
        } else {
            [void]$tfvars.Add("create_sso_permission_sets = true")
            Write-ColorOutput " No existing Permission Sets found" "Yellow"
        }
    } else {
        [void]$tfvars.Add("create_sso_permission_sets = true")
        Write-ColorOutput " SSO not enabled" "Yellow"
    }

    # Write tfvars file
    $tfvars | Out-File -FilePath $OutputFile -Encoding UTF8 -Force
    Write-ColorOutput "`nCreated $OutputFile with existing resource configuration" "Green"

} catch {
    Write-ColorOutput "Error occurred while checking resources: $_" "Red"
    throw $_
}
