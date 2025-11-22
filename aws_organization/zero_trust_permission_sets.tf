# Zero Trust Demo Permission Sets
# These permission sets demonstrate different access levels for Zero Trust implementation

# A. ReadOnlyAccess Permission Set
# Base: AWS Managed Policy - ReadOnlyAccess
# Session Duration: 1 hour
resource "aws_ssoadmin_permission_set" "readonly_access" {
  name             = "ReadOnlyAccess"
  description      = "Zero Trust demo - Read-only access baseline for least privilege"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT1H"  # 1 hour

  tags = {
    Purpose     = "ZeroTrustDemo"
    AccessLevel = "ReadOnly"
    ManagedBy   = "Terraform"
  }
}

# Attach AWS managed ReadOnlyAccess policy
resource "aws_ssoadmin_managed_policy_attachment" "readonly_access_policy" {
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.readonly_access.arn
}

# B. DeveloperAccess Permission Set
# Base: AWS Managed Policy - PowerUserAccess
# Session Duration: 1 hour
resource "aws_ssoadmin_permission_set" "developer_access" {
  name             = "DeveloperAccess"
  description      = "Zero Trust demo - Developer access for general work"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT1H"  # 1 hour

  tags = {
    Purpose     = "ZeroTrustDemo"
    AccessLevel = "Developer"
    ManagedBy   = "Terraform"
  }
}

# Attach AWS managed PowerUserAccess policy
resource "aws_ssoadmin_managed_policy_attachment" "developer_access_policy" {
  instance_arn       = local.sso_instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  permission_set_arn = aws_ssoadmin_permission_set.developer_access.arn
}

# C. CloudOps Permission Set (Elevated - JIT Role)
# Base: Custom Permissions
# Session Duration: 1 hour (short for privileged access)
resource "aws_ssoadmin_permission_set" "cloudops_access" {
  name             = "CloudOpsAccess"
  description      = "Zero Trust demo - Privileged CloudOps access for JIT scenarios"
  instance_arn     = local.sso_instance_arn
  session_duration = "PT1H"  # 1 hour (short for elevated access)

  tags = {
    Purpose     = "ZeroTrustDemo"
    AccessLevel = "Elevated"
    JITEnabled  = "true"
    ManagedBy   = "Terraform"
  }
}

# Custom inline policy for CloudOps with strict admin-lite permissions
resource "aws_ssoadmin_permission_set_inline_policy" "cloudops_custom_policy" {
  inline_policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # IAM readonly permissions
      {
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*",
          "iam:GenerateCredentialReport",
          "iam:GenerateServiceLastAccessedDetails",
          "iam:SimulatePrincipalPolicy",
          "iam:SimulateCustomPolicy"
        ]
        Resource = "*"
      },
      # CloudFormation deploy permissions
      {
        Effect = "Allow"
        Action = [
          "cloudformation:*"
        ]
        Resource = "*"
      },
      # EC2 start/stop permissions
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeImages",
          "ec2:DescribeSnapshots",
          "ec2:DescribeVolumes",
          "ec2:CreateTags",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      },
      # S3 modify permissions
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetObjectVersion",
          "s3:PutObjectAcl",
          "s3:GetObjectAcl",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:GetBucketAcl",
          "s3:GetBucketPolicy"
        ]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      },
      # Additional CloudOps permissions for monitoring and troubleshooting
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:*",
          "logs:*",
          "sns:Publish",
          "lambda:InvokeFunction",
          "lambda:GetFunction",
          "lambda:ListFunctions",
          "autoscaling:Describe*",
          "autoscaling:UpdateAutoScalingGroup",
          "elasticloadbalancing:Describe*"
        ]
        Resource = "*"
      },
      # Systems Manager for operational tasks
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:ListCommands",
          "ssm:ListCommandInvocations",
          "ssm:DescribeInstanceInformation",
          "ssm:GetCommandInvocation",
          "ssm:StartSession",
          "ssm:TerminateSession",
          "ssm:ResumeSession",
          "ssm:DescribeSessions",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      }
    ]
  })
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.cloudops_access.arn
}

# Output the permission set ARNs for reference
output "zero_trust_permission_sets" {
  value = {
    readonly_access = {
      name = aws_ssoadmin_permission_set.readonly_access.name
      arn  = aws_ssoadmin_permission_set.readonly_access.arn
      description = "Least privilege baseline - read-only access"
      session_duration = "1 hour"
    }
    developer_access = {
      name = aws_ssoadmin_permission_set.developer_access.name
      arn  = aws_ssoadmin_permission_set.developer_access.arn
      description = "General work access with PowerUser permissions"
      session_duration = "1 hour"
    }
    cloudops_access = {
      name = aws_ssoadmin_permission_set.cloudops_access.name
      arn  = aws_ssoadmin_permission_set.cloudops_access.arn
      description = "Privileged CloudOps access for JIT scenarios"
      session_duration = "1 hour"
    }
  }
  description = "Zero Trust demo permission sets with different access levels"
}