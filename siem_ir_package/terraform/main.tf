# KMS key for forensic bucket encryption
resource "aws_kms_key" "forensic_kms" {
  description = "KMS key for forensic bucket encryption"
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "forensic_alias" {
  name = "alias/forensic-key"
  target_key_id = aws_kms_key.forensic_kms.key_id
}

# Forensic S3 bucket (Object Lock enabled) - bucket name must be unique
resource "aws_s3_bucket" "forensics" {
  bucket = var.forensic_bucket_name
  acl    = "private"

  versioning { enabled = true }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = aws_kms_key.forensic_kms.arn
      }
    }
  }

  object_lock_configuration {
    object_lock_enabled = "Enabled"
    rule {
      default_retention { mode = "GOVERNANCE"; days = 365 }
    }
  }

  tags = { Name = "forensics-bucket" }
}

# IAM role for Lambda playbooks
data "aws_iam_policy_document" "lambda_assume" {
  statement { actions = ["sts:AssumeRole"]; principals { type = "Service"; identifiers = ["lambda.amazonaws.com"] } }
}

resource "aws_iam_role" "lambda_playbook_role" {
  name = "lambda-playbook-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}

resource "aws_iam_policy" "lambda_playbook_policy" {
  name = "lambda-playbook-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["ec2:DescribeInstances","ec2:CreateSecurityGroup","ec2:ModifyInstanceAttribute","ec2:CreateSnapshot","ec2:DescribeVolumes"], Resource = ["*"] },
      { Effect = "Allow", Action = ["s3:PutObject","s3:GetObject","s3:PutBucketPolicy","s3:PutObjectLegalHold"], Resource = [aws_s3_bucket.forensics.arn + "/*"] },
      { Effect = "Allow", Action = ["iam:ListAccessKeys","iam:UpdateAccessKey","iam:CreateAccessKey"], Resource = ["*"] },
      { Effect = "Allow", Action = ["logs:CreateLogGroup","logs:CreateLogStream","logs:PutLogEvents"], Resource = ["*"] }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_playbook_attach" {
  role = aws_iam_role.lambda_playbook_role.name
  policy_arn = aws_iam_policy.lambda_playbook_policy.arn
}

# Package lambda source using archive_file
data "archive_file" "isolate_zip" {
  type = "zip"
  source_dir = "${path.module}/../lambda_src/isolate_ec2"
  output_path = "${path.module}/../lambda_build/isolate_ec2.zip"
}

resource "aws_lambda_function" "isolate_ec2" {
  filename = data.archive_file.isolate_zip.output_path
  function_name = "isolate_ec2_playbook"
  role = aws_iam_role.lambda_playbook_role.arn
  handler = "isolate_ec2.lambda_handler"
  runtime = "python3.11"
  timeout = var.lambda_timeout

  environment {
    variables = {
      FORENSIC_BUCKET = aws_s3_bucket.forensics.bucket
    }
  }
}

data "archive_file" "lockdown_zip" {
  type = "zip"
  source_dir = "${path.module}/../lambda_src/lockdown_s3"
  output_path = "${path.module}/../lambda_build/lockdown_s3.zip"
}

resource "aws_lambda_function" "lockdown_s3" {
  filename = data.archive_file.lockdown_zip.output_path
  function_name = "lockdown_s3_playbook"
  role = aws_iam_role.lambda_playbook_role.arn
  handler = "lockdown_s3.lambda_handler"
  runtime = "python3.11"
  timeout = var.lambda_timeout

  environment {
    variables = {
      FORENSIC_BUCKET = aws_s3_bucket.forensics.bucket
    }
  }
}

data "archive_file" "revoke_zip" {
  type = "zip"
  source_dir = "${path.module}/../lambda_src/revoke_iam"
  output_path = "${path.module}/../lambda_build/revoke_iam.zip"
}

resource "aws_lambda_function" "revoke_iam" {
  filename = data.archive_file.revoke_zip.output_path
  function_name = "revoke_iam_playbook"
  role = aws_iam_role.lambda_playbook_role.arn
  handler = "revoke_iam.lambda_handler"
  runtime = "python3.11"
  timeout = var.lambda_timeout
}

# EventBridge rule for GuardDuty findings -> isolate EC2
resource "aws_cloudwatch_event_rule" "guardduty_rule" {
  name = "guardduty-findings-rule"
  event_pattern = jsonencode({
    source = ["aws.guardduty"],
    "detail-type" = ["GuardDuty Finding"]
  })
}

resource "aws_cloudwatch_event_target" "guardduty_to_isolate" {
  rule = aws_cloudwatch_event_rule.guardduty_rule.name
  arn  = aws_lambda_function.isolate_ec2.arn
}

resource "aws_lambda_permission" "allow_eventbridge_isolate" {
  statement_id = "AllowEventBridgeInvokeIsolate"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.isolate_ec2.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.guardduty_rule.arn
}

# EventBridge rule for S3 object-level anomalies (Object Level API via CloudTrail)
resource "aws_cloudwatch_event_rule" "s3_object_events" {
  name = "s3-object-events-rule"
  event_pattern = jsonencode({
    source = ["aws.s3"],
    detail = {
      eventName = ["PutObject","DeleteObject","DeleteObjectTagging"]
    }
  })
}

resource "aws_cloudwatch_event_target" "s3_to_lockdown" {
  rule = aws_cloudwatch_event_rule.s3_object_events.name
  arn  = aws_lambda_function.lockdown_s3.arn
}

resource "aws_lambda_permission" "allow_eventbridge_lockdown" {
  statement_id = "AllowEventBridgeInvokeLockdown"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lockdown_s3.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.s3_object_events.arn
}

# EventBridge rule for IAM Change events (CloudTrail) e.g., CreateAccessKey, UpdateAccessKey
resource "aws_cloudwatch_event_rule" "iam_key_events" {
  name = "iam-key-events-rule"
  event_pattern = jsonencode({
    source = ["aws.iam"],
    detail = {
      eventName = ["CreateAccessKey","UpdateAccessKey","DeleteAccessKey","ConsoleLogin"]
    }
  })
}

resource "aws_cloudwatch_event_target" "iam_to_revoke" {
  rule = aws_cloudwatch_event_rule.iam_key_events.name
  arn  = aws_lambda_function.revoke_iam.arn
}

resource "aws_lambda_permission" "allow_eventbridge_revoke" {
  statement_id = "AllowEventBridgeInvokeRevoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.revoke_iam.function_name
  principal = "events.amazonaws.com"
  source_arn = aws_cloudwatch_event_rule.iam_key_events.arn
}

# Optional: upload OpenSearch Dashboards saved objects into OpenSearch via API (user must provide endpoint)
resource "local_file" "opensearch_dashboard_instructions" {
  content = <<EOF
OpenSearch Dashboards saved objects are included in the opensearch_dashboards/ folder.
To import:
1. Open OpenSearch Dashboards -> Management -> Saved Objects
2. Import each JSON file for dashboards and visualizations
Or use the Saved Objects API to bulk import.
EOF
  filename = "${path.module}/opensearch_import_instructions.txt"
}
