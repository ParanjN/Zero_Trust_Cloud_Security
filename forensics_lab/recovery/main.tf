# Recovery Configuration for Forensics Lab

# Automated EBS Snapshots
resource "aws_dlm_lifecycle_policy" "ebs_policy" {
  description        = "EBS snapshot policy for forensics lab"
  execution_role_arn = aws_iam_role.dlm_role.arn
  state             = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "2 weeks of daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times        = ["23:45"]
      }

      retain_rule {
        count = 14
      }

      copy_tags = true
    }

    target_tags = {
      Backup = "true"
    }
  }

  tags = var.tags
}

# RDS Automated Backups
resource "aws_db_instance" "forensics_db" {
  # ... other configuration ...

  backup_retention_period = 14
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"

  copy_tags_to_snapshot = true
  deletion_protection   = true

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
}

# S3 Versioning and MFA Delete
resource "aws_s3_bucket" "protected_data" {
  bucket = "protected-data-${data.aws_caller_identity.current.account_id}"

  versioning {
    enabled    = true
    mfa_delete = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = aws_kms_key.protected_data.id
      }
    }
  }

  tags = var.tags
}

# DynamoDB Point-in-Time Recovery
resource "aws_dynamodb_table" "forensics_table" {
  name           = "forensics-data"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"
  range_key      = "timestamp"

  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  tags = var.tags
}

# Recovery Runbooks (SSM Automation)
resource "aws_ssm_document" "ec2_recovery" {
  name            = "EC2RecoveryFromSnapshot"
  document_type   = "Automation"
  document_format = "YAML"

  content = templatefile("${path.module}/templates/ec2_recovery.yml", {
    region = var.aws_region
  })

  tags = var.tags
}

resource "aws_ssm_document" "rds_recovery" {
  name            = "RDSRecoveryFromSnapshot"
  document_type   = "Automation"
  document_format = "YAML"

  content = templatefile("${path.module}/templates/rds_recovery.yml", {
    region = var.aws_region
  })

  tags = var.tags
}

# CloudWatch Event Rules for Automated Recovery
resource "aws_cloudwatch_event_rule" "ec2_failure" {
  name        = "detect-ec2-failure"
  description = "Detect EC2 instance failures"

  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["stopped", "terminated"]
    }
  })

  tags = var.tags
}

resource "aws_cloudwatch_event_target" "ec2_recovery" {
  rule      = aws_cloudwatch_event_rule.ec2_failure.name
  target_id = "EC2Recovery"
  arn       = "arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:automation-definition/${aws_ssm_document.ec2_recovery.name}:$DEFAULT"
  role_arn  = aws_iam_role.event_role.arn
}