# EventBridge Rules for Security Services
resource "aws_cloudwatch_event_rule" "securityhub_rule" {
  name = "${var.project_prefix}-securityhub-rule"
  event_pattern = jsonencode({
    "source": ["aws.securityhub"],
    "detail-type": ["Security Hub Findings - Imported"]
  })
}

resource "aws_cloudwatch_event_target" "securityhub_target" {
  rule      = aws_cloudwatch_event_rule.securityhub_rule.name
  target_id = "ingest-lambda"
  arn       = aws_lambda_function.ingest_lambda.arn
}

resource "aws_cloudwatch_event_rule" "guardduty_rule" {
  name = "${var.project_prefix}-guardduty-rule"
  event_pattern = jsonencode({
    "source": ["aws.guardduty"],
    "detail-type": ["GuardDuty Finding"]
  })
}

resource "aws_cloudwatch_event_target" "guardduty_target" {
  rule      = aws_cloudwatch_event_rule.guardduty_rule.name
  target_id = "ingest-lambda-gd"
  arn       = aws_lambda_function.ingest_lambda.arn
}

resource "aws_cloudwatch_event_rule" "config_rule" {
  name = "${var.project_prefix}-config-rule"
  event_pattern = jsonencode({
    "source": ["aws.config"],
    "detail-type": ["Config Rules Compliance Change","Config Snapshot Delivery State Change"]
  })
}

resource "aws_cloudwatch_event_target" "config_target" {
  rule      = aws_cloudwatch_event_rule.config_rule.name
  target_id = "ingest-lambda-cfg"
  arn       = aws_lambda_function.ingest_lambda.arn
}

resource "aws_cloudwatch_event_rule" "auditmanager_rule" {
  name = "${var.project_prefix}-auditmanager-rule"
  event_pattern = jsonencode({
    "source": ["aws.auditmanager"],
    "detail-type": ["Audit Manager Assessment Report"]
  })
}

resource "aws_cloudwatch_event_target" "auditmanager_target" {
  rule      = aws_cloudwatch_event_rule.auditmanager_rule.name
  target_id = "ingest-lambda-am"
  arn       = aws_lambda_function.ingest_lambda.arn
}