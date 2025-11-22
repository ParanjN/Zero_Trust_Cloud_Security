# AWS Audit Manager Configuration

# Enable Audit Manager
resource "aws_auditmanager_organization_admin_account_registration" "admin" {
  admin_account_id = data.aws_caller_identity.current.account_id
  depends_on       = [aws_organizations_organization.org]
}

# Create Assessment for CIS AWS Foundations Benchmark
resource "aws_auditmanager_assessment" "cis_assessment" {
  name = "CIS-AWS-Foundations-Assessment"
  
  framework_id = "aws-foundational-security-best-practices-v1.0.0"
  
  scope {
    aws_accounts {
      id = data.aws_caller_identity.current.account_id
    }
    aws_services {
      service_name = "AWS_ACCOUNT"
    }
  }

  roles {
    role_type = "PROCESS_OWNER"
    role_arn  = aws_iam_role.audit_manager_role.arn
  }

  depends_on = [aws_auditmanager_organization_admin_account_registration.admin]
}

# Create Assessment for NIST CSF
resource "aws_auditmanager_assessment" "nist_assessment" {
  name = "NIST-CSF-Assessment"
  
  framework_id = "nist-csf-v1.1"
  
  scope {
    aws_accounts {
      id = data.aws_caller_identity.current.account_id
    }
    aws_services {
      service_name = "AWS_ACCOUNT"
    }
  }

  roles {
    role_type = "PROCESS_OWNER"
    role_arn  = aws_iam_role.audit_manager_role.arn
  }

  depends_on = [aws_auditmanager_organization_admin_account_registration.admin]
}