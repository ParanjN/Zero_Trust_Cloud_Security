# QuickSight Data Source and Dataset Configuration
# Commented out until QuickSight is manually initialized
# 
# resource "aws_quicksight_data_source" "athena_ds" {
#   data_source_id = "${var.project_prefix}-athena-ds-${random_id.suffix.hex}"
#   name           = "${var.project_prefix}-athena-ds"
#   type           = "ATHENA"
#   aws_account_id = data.aws_caller_identity.current.account_id
#   
#   depends_on = [
#     aws_quicksight_account_subscription.subscription,
#     aws_quicksight_user.admin_user
#   ]
#   
#   parameters {
#     athena {
#       work_group = aws_athena_workgroup.wg.name
#     }
#   }
# }
# 
# resource "aws_quicksight_data_set" "findings_ds" {
#   aws_account_id = data.aws_caller_identity.current.account_id
#   data_set_id    = "${var.project_prefix}-findings-ds-${random_id.suffix.hex}"
#   name           = "${var.project_prefix}-findings-ds"
#   import_mode    = "DIRECT_QUERY"
#   
#   physical_table_map {
#     physical_table_map_id = "findings_table"
#     custom_sql {
#       data_source_arn = aws_quicksight_data_source.athena_ds.arn
#       name            = "findings_custom_sql"
#       sql_query       = "SELECT * FROM ${aws_glue_catalog_database.findings_db.name}.findings_table LIMIT 1000"
#     }
#   }
# 
#   logical_table_map {
#     logical_table_map_id = "findings_logical_table"
#     alias = "findings"
#     source {
#       physical_table_id = "findings_table"
#     }
#   }
# }