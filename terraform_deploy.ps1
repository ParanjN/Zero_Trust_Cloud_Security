$ErrorActionPreference = "Stop"
$logFile = "terraform_deploy.log"

function Write-Log {
    param($Message)
    $logMessage = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): $Message"
    Write-Host $logMessage
    Add-Content -Path $logFile -Value $logMessage
}

try {
    Write-Log "Starting pre-deployment resource check..."
    
    # Generate tfvars file based on existing resources
    Write-Log "Checking existing resources..."
    .\generate_tfvars.ps1
    Write-Log "Resource check completed and tfvars file generated"
    
    Write-Log "Starting Terraform deployment..."
    
    # Initialize Terraform
    Write-Log "Running terraform init..."
    terraform init
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform init failed with exit code $LASTEXITCODE"
    }
    Write-Log "Terraform init completed successfully"
    
    # Run Terraform plan
    Write-Log "Running terraform plan..."
    terraform plan -out=tfplan
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform plan failed with exit code $LASTEXITCODE"
    }
    Write-Log "Terraform plan completed successfully"
    
    # Apply the Terraform plan
    Write-Log "Running terraform apply..."
    terraform apply -auto-approve "tfplan"
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform apply failed with exit code $LASTEXITCODE"
    }
    Write-Log "Terraform apply completed successfully"

    Write-Log "Deployment script completed successfully"
} catch {
    Write-Log "ERROR: $_"
    Write-Log $_.ScriptStackTrace
    exit 1
} finally {
    # Cleanup the plan file if it exists
    if (Test-Path "tfplan") {
        Remove-Item "tfplan"
        Write-Log "Cleaned up terraform plan file"
    }
}