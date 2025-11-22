# Organization CloudTrail
resource "aws_cloudtrail" "org_trail" {
  count = var.create_cloudtrail ? 1 : 0

  name                          = var.existing_cloudtrail_name != null ? var.existing_cloudtrail_name : "organization-trail"
  is_multi_region_trail         = true
  include_global_service_events = true
  is_organization_trail         = true
  s3_bucket_name                = var.create_log_bucket ? aws_s3_bucket.log_archive[0].id : var.existing_log_bucket_name
  enable_log_file_validation    = true
  kms_key_id                    = var.existing_kms_key_id != null ? var.existing_kms_key_id : try(aws_kms_key.log_bucket_key[0].arn, null)

  depends_on = [
    data.aws_organizations_organization.org,
    aws_s3_bucket.log_archive,
    aws_s3_bucket_server_side_encryption_configuration.log_bucket_sse
  ]
}