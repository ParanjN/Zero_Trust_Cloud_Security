# SCP Policies
# 1) Deny disabling CloudTrail & GuardDuty
resource "aws_organizations_policy" "deny_disable_ct_gd" {
  name        = "DenyDisableCloudTrailGuardDuty"
  description = "Deny actions that disable CloudTrail or GuardDuty"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Deny",
        Action = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail",
          "guardduty:DisassociateFromMasterAccount",
          "guardduty:DeleteDetector"
        ],
        Resource = "*"
      }
    ]
  })
}

# 2) Deny root actions
resource "aws_organizations_policy" "deny_root_actions" {
  name        = "DenyRootActions"
  description = "Deny actions by the root principal"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Deny",
        Action = "*",
        Resource = "*",
        Condition = {
          StringLike = {
            "aws:PrincipalArn": "arn:aws:iam::*:root"
          }
        }
      }
    ]
  })
}

# 3) Enforce specific regions
resource "aws_organizations_policy" "restrict_regions" {
  name        = "RestrictRegions"
  description = "Allow only specified regions"
  type        = "SERVICE_CONTROL_POLICY"
  content     = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Deny",
        Action = "*",
        Resource = "*",
        Condition = {
          StringNotLike = {
            "aws:RequestedRegion": var.allowed_regions
          }
        }
      }
    ]
  })
}

# Enable Service Control Policies in the organization
resource "null_resource" "enable_service_control_policies" {
  provisioner "local-exec" {
    command     = "aws organizations enable-policy-type --root-id ${data.aws_organizations_organization.org.roots[0].id} --policy-type SERVICE_CONTROL_POLICY"
    interpreter = ["PowerShell", "-Command"]
  }

  # Trigger when organization root changes
  triggers = {
    root_id = data.aws_organizations_organization.org.roots[0].id
  }
}

# Wait for policy type to be enabled
resource "time_sleep" "wait_for_policy_type" {
  depends_on = [null_resource.enable_service_control_policies]
  create_duration = "30s"
}

# Policy Attachments
resource "aws_organizations_policy_attachment" "attach_deny_disable_ct_gd_root" {
  policy_id = aws_organizations_policy.deny_disable_ct_gd.id
  target_id = data.aws_organizations_organization.org.roots[0].id
  depends_on = [time_sleep.wait_for_policy_type]
}

resource "aws_organizations_policy_attachment" "attach_deny_root_root" {
  policy_id = aws_organizations_policy.deny_root_actions.id
  target_id = data.aws_organizations_organization.org.roots[0].id
  depends_on = [time_sleep.wait_for_policy_type]
}

resource "aws_organizations_policy_attachment" "attach_restrict_regions_root" {
  policy_id = aws_organizations_policy.restrict_regions.id
  target_id = data.aws_organizations_organization.org.roots[0].id
  depends_on = [time_sleep.wait_for_policy_type]
}