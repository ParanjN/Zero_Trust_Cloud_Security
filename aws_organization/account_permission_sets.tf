# Account-specific Permission Sets with Minimal Privileges

# Local variables for permission set configurations
locals {
  # Define account-specific permission sets with minimal privileges
  account_permission_sets = {
    security = {
      name = "SecurityAccountAccess"
      description = "Minimal security account access for security operations"
      session_duration = "PT2H"  # 2 hours
      managed_policies = [
        "arn:aws:iam::aws:policy/SecurityAudit",
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "config:*",
              "cloudtrail:*",
              "guardduty:*",
              "securityhub:*",
              "inspector:*",
              "access-analyzer:*",
              "detective:*",
              "macie2:*"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "iam:GetRole",
              "iam:GetRolePolicy", 
              "iam:ListRoles",
              "iam:ListRolePolicies",
              "iam:ListAttachedRolePolicies"
            ]
            Resource = "*"
          }
        ]
      })
    }

    logging = {
      name = "LoggingAccountAccess"
      description = "Minimal logging account access for log management"
      session_duration = "PT2H"
      managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "logs:*",
              "cloudtrail:*",
              "s3:GetObject",
              "s3:PutObject",
              "s3:ListBucket",
              "s3:GetBucketLocation",
              "kinesis:*",
              "firehose:*",
              "elasticsearch:*",
              "opensearch:*"
            ]
            Resource = "*"
          }
        ]
      })
    }

    sandbox = {
      name = "SandboxAccountAccess"
      description = "Development and testing access for sandbox environment"
      session_duration = "PT4H"  # 4 hours for development work
      managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Action = [
              "organizations:*",
              "account:*",
              "iam:CreateUser",
              "iam:DeleteUser",
              "iam:CreateRole",
              "iam:DeleteRole",
              "iam:AttachUserPolicy",
              "iam:AttachRolePolicy",
              "iam:DetachUserPolicy",
              "iam:DetachRolePolicy"
            ]
            Resource = "*"
          }
        ]
      })
    }

    prod = {
      name = "ProdAccountAccess"
      description = "Production environment access with strict controls"
      session_duration = "PT1H"  # 1 hour for production
      managed_policies = [
        "arn:aws:iam::aws:policy/ReadOnlyAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "cloudwatch:*",
              "logs:DescribeLogGroups",
              "logs:DescribeLogStreams",
              "logs:GetLogEvents",
              "ec2:DescribeInstances",
              "ec2:DescribeInstanceStatus",
              "rds:DescribeDBInstances",
              "lambda:GetFunction",
              "lambda:ListFunctions"
            ]
            Resource = "*"
          }
        ]
      })
    }

    devtest = {
      name = "DevTestAccountAccess"
      description = "Development and testing environment access"
      session_duration = "PT8H"  # 8 hours for development work
      managed_policies = [
        "arn:aws:iam::aws:policy/PowerUserAccess"
      ]
      inline_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Deny"
            Action = [
              "organizations:*",
              "account:*"
            ]
            Resource = "*"
          },
          {
            Effect = "Allow"
            Action = [
              "iam:PassRole"
            ]
            Resource = "arn:aws:iam::*:role/*"
            Condition = {
              StringEquals = {
                "iam:PassedToService" = [
                  "ec2.amazonaws.com",
                  "lambda.amazonaws.com",
                  "ecs-tasks.amazonaws.com"
                ]
              }
            }
          }
        ]
      })
    }
  }
}

# Create permission sets for each account type
resource "aws_ssoadmin_permission_set" "account_permission_sets" {
  for_each = local.account_permission_sets

  instance_arn     = local.sso_instance_arn
  name             = each.value.name
  description      = each.value.description
  session_duration = each.value.session_duration

  tags = {
    ManagedBy = "Terraform"
    Purpose   = each.key
  }

  depends_on = [data.aws_ssoadmin_instances.sso]
}

# Attach managed policies to permission sets
resource "aws_ssoadmin_managed_policy_attachment" "account_permission_sets" {
  for_each = {
    for combo in flatten([
      for ps_key, ps_config in local.account_permission_sets : [
        for policy in ps_config.managed_policies : {
          ps_key = ps_key
          policy_arn = policy
          key = "${ps_key}-${replace(policy, ":", "-")}"
        }
      ]
    ]) : combo.key => combo
  }

  instance_arn       = local.sso_instance_arn
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.account_permission_sets[each.value.ps_key].arn

  depends_on = [aws_ssoadmin_permission_set.account_permission_sets]
}

# Attach inline policies to permission sets
resource "aws_ssoadmin_permission_set_inline_policy" "account_permission_sets" {
  for_each = local.account_permission_sets

  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.account_permission_sets[each.key].arn
  inline_policy      = each.value.inline_policy

  depends_on = [aws_ssoadmin_permission_set.account_permission_sets]
}

# Note: Account assignments will be created separately to avoid circular dependencies
# You can manually assign these permission sets to the admin group through the AWS console
# or create assignments in a separate terraform apply after both modules are deployed

# Output permission set ARNs
output "account_permission_sets" {
  value = {
    for k, v in aws_ssoadmin_permission_set.account_permission_sets : 
    k => {
      arn = v.arn
      name = v.name
    }
  }
  description = "Account-specific permission set ARNs"
}