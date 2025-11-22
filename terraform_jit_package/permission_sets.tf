resource "aws_ssoadmin_permission_set" "ps" {
  for_each = local.permission_sets

  instance_arn     = var.identity_center_instance_arn
  name             = each.key
  description      = each.value.description
  session_duration = each.value.session_duration
}

locals {
  ps_policy_pairs = flatten([
    for ps_name, ps in local.permission_sets : [
      for policy in ps.managed_policies : {
        ps_name = ps_name
        policy  = policy
      }
    ]
  ])
}

resource "aws_ssoadmin_managed_policy_attachment" "ps_policy_attach" {
  for_each = {
    for pair in local.ps_policy_pairs :
    "${pair.ps_name}-${replace(replace(pair.policy, "arn:aws:iam::aws:policy/", ""), "/", "-")}" => pair
  }

  instance_arn       = var.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.ps[each.value.ps_name].arn
  managed_policy_arn = each.value.policy
}
