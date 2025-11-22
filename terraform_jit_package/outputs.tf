output "jit_create_lambda_arn" {
  value = aws_lambda_function.jit_create.arn
}

output "jit_cleanup_lambda_arn" {
  value = aws_lambda_function.jit_cleanup.arn
}

output "permission_sets" {
  value = { for k, v in aws_ssoadmin_permission_set.ps : k => v.arn }
}

output "admin_group_id" {
  value = aws_identitystore_group.admins.group_id
  description = "ID of the admin group for account assignments"
}
