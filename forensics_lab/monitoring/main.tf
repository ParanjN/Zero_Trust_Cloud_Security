# Monitoring Configuration for Forensics Lab

# S3 Bucket for Forensics Data with Object Lock
resource "aws_s3_bucket" "forensics" {
  bucket = "forensics-data-${data.aws_caller_identity.current.account_id}"

  object_lock_enabled = true

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        kms_master_key_id = aws_kms_key.forensics.id
      }
    }
  }

  tags = var.tags
}

# Object Lock Configuration
resource "aws_s3_bucket_object_lock_configuration" "forensics" {
  bucket = aws_s3_bucket.forensics.id

  rule {
    default_retention {
      mode = "COMPLIANCE"
      days = 365
    }
  }
}

# VPC Flow Logs Configuration
resource "aws_flow_log" "forensics_vpc" {
  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_s3_bucket.forensics.arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id

  tags = merge(var.tags, {
    Name = "forensics-vpc-flow-logs"
  })
}

# GuardDuty Findings Export
resource "aws_guardduty_detector" "forensics" {
  enable = true

  datasources {
    s3_logs {
      enable = true
    }
    kubernetes {
      audit_logs {
        enable = true
      }
    }
  }

  finding_publishing_frequency = "FIFTEEN_MINUTES"

  tags = var.tags
}

resource "aws_guardduty_publishing_destination" "forensics" {
  detector_id     = aws_guardduty_detector.forensics.id
  destination_arn = aws_s3_bucket.forensics.arn
  kms_key_arn    = aws_kms_key.forensics.arn
}

# CloudWatch Log Groups for EC2 Instances
resource "aws_cloudwatch_log_group" "ec2_logs" {
  name              = "/aws/ec2/forensics-lab"
  retention_in_days = 90

  tags = var.tags
}

# CloudWatch Log Groups for RDS
resource "aws_cloudwatch_log_group" "rds_logs" {
  name              = "/aws/rds/forensics-lab"
  retention_in_days = 90

  tags = var.tags
}

# CloudWatch Alarms for Suspicious Activity
resource "aws_cloudwatch_metric_alarm" "suspicious_api_calls" {
  alarm_name          = "suspicious-api-calls"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "UnauthorizedAttemptCount"
  namespace           = "AWS/CloudTrail"
  period              = "300"
  statistic          = "Sum"
  threshold          = "10"
  alarm_description  = "This metric monitors suspicious API calls"
  alarm_actions      = [aws_sns_topic.security_alerts.arn]

  dimensions = {
    EventName = "ConsoleLogin"
  }
}

# SNS Topic for Security Alerts
resource "aws_sns_topic" "security_alerts" {
  name = "forensics-lab-security-alerts"

  tags = var.tags
}