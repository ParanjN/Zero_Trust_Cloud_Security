# QuickSight requires manual initialization before Terraform can manage it
# Please manually set up QuickSight in the AWS console first
# 
# # Initialize QuickSight account
# resource "aws_quicksight_account_subscription" "subscription" {
#   account_name          = "risk-compliance-dashboard"
#   authentication_method = "IAM_AND_QUICKSIGHT"
#   edition              = "ENTERPRISE"
#   notification_email   = "nachiketparanjape123@gmail.com"
# 
#   # Add AWS services that QuickSight can access
#   aws_account_id = data.aws_caller_identity.current.account_id
# }
# 
# # Create QuickSight user
# resource "aws_quicksight_user" "admin_user" {
#   aws_account_id = data.aws_caller_identity.current.account_id
#   email          = "nachiketparanjape123@gmail.com"
#   identity_type  = "QUICKSIGHT"
#   namespace      = var.quicksight_namespace
#   user_name      = "admin"
#   user_role      = "ADMIN"
# 
#   depends_on = [aws_quicksight_account_subscription.subscription]
# }