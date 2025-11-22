# AWS Config Setup and Conformance Packs

# Enable AWS Config
resource "aws_config_configuration_recorder" "org_recorder" {
  name     = "config-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
    include_global_resources = true
  }
}

resource "aws_config_configuration_recorder_status" "org_recorder_status" {
  name       = aws_config_configuration_recorder.org_recorder.name
  is_enabled = true
  depends_on = [aws_config_configuration_recorder.org_recorder]
}

# CIS AWS Foundations Benchmark Conformance Pack
resource "aws_config_conformance_pack" "cis_benchmark" {
  name = "cis-aws-foundations-benchmark"

  template_body = file("${path.module}/templates/cis-conformance-pack.yml")

  depends_on = [aws_config_configuration_recorder.org_recorder]
}

# NIST CSF Conformance Pack
resource "aws_config_conformance_pack" "nist_csf" {
  name = "nist-csf-pack"

  template_body = file("${path.module}/templates/nist-csf-conformance-pack.yml")

  depends_on = [aws_config_configuration_recorder.org_recorder]
}

# Custom Config Rules
resource "aws_config_config_rule" "s3_encryption" {
  name = "s3-bucket-encryption"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.org_recorder]
}

resource "aws_config_config_rule" "iam_policy_no_star" {
  name = "iam-policy-no-full-star"

  source {
    owner             = "AWS"
    source_identifier = "IAM_POLICY_NO_STATEMENTS_WITH_ADMIN_ACCESS"
  }

  depends_on = [aws_config_configuration_recorder.org_recorder]
}

resource "aws_config_config_rule" "cloudtrail_enabled" {
  name = "cloudtrail-enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.org_recorder]
}