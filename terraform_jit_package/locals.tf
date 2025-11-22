locals {
  permission_sets = {
    Admin = {
      description      = "Administrator access"
      managed_policies = ["arn:aws:iam::aws:policy/AdministratorAccess"]
      session_duration = "PT4H"
    }
    DevOps = {
      description      = "DevOps / PowerUser"
      managed_policies = ["arn:aws:iam::aws:policy/PowerUserAccess"]
      session_duration = "PT2H"
    }
    ReadOnly = {
      description      = "ReadOnly Access"
      managed_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
      session_duration = "PT1H"
    }
  }
}
