# Account-specific users for different permission sets

# Create users for each account type/role
resource "aws_identitystore_user" "security_admin" {
  identity_store_id = local.identity_store_id

  display_name = "Security Administrator"
  user_name    = "security.admin"
  
  name {
    given_name  = "Security"
    family_name = "Administrator"
  }

  emails {
    value   = "nachiketparanjape123+security.admin@gmail.com"
    type    = "work"
    primary = true
  }
}

resource "aws_identitystore_user" "logging_admin" {
  identity_store_id = local.identity_store_id

  display_name = "Logging Administrator"
  user_name    = "logging.admin"
  
  name {
    given_name  = "Logging"
    family_name = "Administrator"
  }

  emails {
    value   = "nachiketparanjape123+logging.admin@gmail.com"
    type    = "work"
    primary = true
  }
}

resource "aws_identitystore_user" "prod_operator" {
  identity_store_id = local.identity_store_id

  display_name = "Production Operator"
  user_name    = "prod.operator"
  
  name {
    given_name  = "Production"
    family_name = "Operator"
  }

  emails {
    value   = "nachiketparanjape123+prod.operator@gmail.com"
    type    = "work"
    primary = true
  }
}

resource "aws_identitystore_user" "sandbox_developer" {
  identity_store_id = local.identity_store_id

  display_name = "Sandbox Developer"
  user_name    = "sandbox.dev"
  
  name {
    given_name  = "Sandbox"
    family_name = "Developer"
  }

  emails {
    value   = "nachiketparanjape123+sandbox.dev@gmail.com"
    type    = "work"
    primary = true
  }
}

resource "aws_identitystore_user" "devtest_engineer" {
  identity_store_id = local.identity_store_id

  display_name = "DevTest Engineer"
  user_name    = "devtest.engineer"
  
  name {
    given_name  = "DevTest"
    family_name = "Engineer"
  }

  emails {
    value   = "nachiketparanjape123+devtest.engineer@gmail.com"
    type    = "work"
    primary = true
  }
}

# Create groups for each account type
resource "aws_identitystore_group" "security_team" {
  identity_store_id = local.identity_store_id
  display_name      = "SecurityTeam"
  description       = "Security team members with access to security account"
}

resource "aws_identitystore_group" "logging_team" {
  identity_store_id = local.identity_store_id
  display_name      = "LoggingTeam"
  description       = "Logging team members with access to logging account"
}

resource "aws_identitystore_group" "prod_operators" {
  identity_store_id = local.identity_store_id
  display_name      = "ProdOperators"
  description       = "Production operators with read-only access to production account"
}

resource "aws_identitystore_group" "sandbox_developers" {
  identity_store_id = local.identity_store_id
  display_name      = "SandboxDevelopers"
  description       = "Developers with power user access to sandbox account"
}

resource "aws_identitystore_group" "devtest_engineers" {
  identity_store_id = local.identity_store_id
  display_name      = "DevTestEngineers"
  description       = "Engineers with development access to devtest account"
}

# Add users to their respective groups
resource "aws_identitystore_group_membership" "security_admin_membership" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.security_team.group_id
  member_id         = aws_identitystore_user.security_admin.user_id
}

resource "aws_identitystore_group_membership" "logging_admin_membership" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.logging_team.group_id
  member_id         = aws_identitystore_user.logging_admin.user_id
}

resource "aws_identitystore_group_membership" "prod_operator_membership" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.prod_operators.group_id
  member_id         = aws_identitystore_user.prod_operator.user_id
}

resource "aws_identitystore_group_membership" "sandbox_developer_membership" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.sandbox_developers.group_id
  member_id         = aws_identitystore_user.sandbox_developer.user_id
}

resource "aws_identitystore_group_membership" "devtest_engineer_membership" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.devtest_engineers.group_id
  member_id         = aws_identitystore_user.devtest_engineer.user_id
}

# Create account assignments for each group to their respective accounts
resource "aws_ssoadmin_account_assignment" "security_team_assignment" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.account_permission_sets["security"].arn
  principal_id       = aws_identitystore_group.security_team.group_id
  principal_type     = "GROUP"
  target_id          = "686662444937"  # Security account ID
  target_type        = "AWS_ACCOUNT"

  depends_on = [
    aws_ssoadmin_permission_set.account_permission_sets,
    aws_identitystore_group.security_team
  ]
}

resource "aws_ssoadmin_account_assignment" "logging_team_assignment" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.account_permission_sets["logging"].arn
  principal_id       = aws_identitystore_group.logging_team.group_id
  principal_type     = "GROUP"
  target_id          = "843508809766"  # Logging account ID
  target_type        = "AWS_ACCOUNT"

  depends_on = [
    aws_ssoadmin_permission_set.account_permission_sets,
    aws_identitystore_group.logging_team
  ]
}

resource "aws_ssoadmin_account_assignment" "prod_operators_assignment" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.account_permission_sets["prod"].arn
  principal_id       = aws_identitystore_group.prod_operators.group_id
  principal_type     = "GROUP"
  target_id          = "464115713885"  # Prod account ID
  target_type        = "AWS_ACCOUNT"

  depends_on = [
    aws_ssoadmin_permission_set.account_permission_sets,
    aws_identitystore_group.prod_operators
  ]
}

resource "aws_ssoadmin_account_assignment" "sandbox_developers_assignment" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.account_permission_sets["sandbox"].arn
  principal_id       = aws_identitystore_group.sandbox_developers.group_id
  principal_type     = "GROUP"
  target_id          = "708403786005"  # Sandbox account ID
  target_type        = "AWS_ACCOUNT"

  depends_on = [
    aws_ssoadmin_permission_set.account_permission_sets,
    aws_identitystore_group.sandbox_developers
  ]
}

resource "aws_ssoadmin_account_assignment" "devtest_engineers_assignment" {
  instance_arn       = local.sso_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.account_permission_sets["devtest"].arn
  principal_id       = aws_identitystore_group.devtest_engineers.group_id
  principal_type     = "GROUP"
  target_id          = "144991380683"  # DevTest account ID
  target_type        = "AWS_ACCOUNT"

  depends_on = [
    aws_ssoadmin_permission_set.account_permission_sets,
    aws_identitystore_group.devtest_engineers
  ]
}

# Output user and group information
output "account_users" {
  value = {
    security_admin = {
      user_id = aws_identitystore_user.security_admin.user_id
      email = "nachiketparanjape123+security.admin@gmail.com"
      account = "security"
    }
    logging_admin = {
      user_id = aws_identitystore_user.logging_admin.user_id
      email = "nachiketparanjape123+logging.admin@gmail.com"
      account = "logging"
    }
    prod_operator = {
      user_id = aws_identitystore_user.prod_operator.user_id
      email = "nachiketparanjape123+prod.operator@gmail.com"
      account = "prod"
    }
    sandbox_developer = {
      user_id = aws_identitystore_user.sandbox_developer.user_id
      email = "nachiketparanjape123+sandbox.dev@gmail.com"
      account = "sandbox"
    }
    devtest_engineer = {
      user_id = aws_identitystore_user.devtest_engineer.user_id
      email = "nachiketparanjape123+devtest.engineer@gmail.com"
      account = "devtest"
    }
  }
  description = "Account-specific users and their details"
}

output "account_groups" {
  value = {
    security_team = aws_identitystore_group.security_team.group_id
    logging_team = aws_identitystore_group.logging_team.group_id
    prod_operators = aws_identitystore_group.prod_operators.group_id
    sandbox_developers = aws_identitystore_group.sandbox_developers.group_id
    devtest_engineers = aws_identitystore_group.devtest_engineers.group_id
  }
  description = "Account-specific groups"
}