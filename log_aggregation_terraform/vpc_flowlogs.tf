# Create VPC Flow Logs for each VPC ID provided in var.vpc_ids.

data "aws_partition" "current" {}

data "aws_iam_policy_document" "flowlogs_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service"; identifiers = ["vpc-flow-logs.amazonaws.com"] }
  }
}

resource "aws_iam_role" "flowlog_role" {
  name               = "flowlogs-role"
  assume_role_policy = data.aws_iam_policy_document.flowlogs_assume.json
}

resource "aws_iam_policy" "flowlog_policy" {
  name = "flowlogs-s3-access"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = ["s3:PutObject","s3:PutObjectAcl"], Resource = ["${aws_s3_bucket.log_bucket.arn}/*"] }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "flowlog_attach" {
  role       = aws_iam_role.flowlog_role.name
  policy_arn = aws_iam_policy.flowlog_policy.arn
}

resource "aws_flow_log" "vpc_flow_logs" {
  for_each = { for id in var.vpc_ids : id => id }

  resource_id          = each.value
  resource_type        = "VPC"
  traffic_type         = "ALL"
  log_destination_type = var.flow_log_destination_type == "s3" ? "s3" : "cloud-watch-logs"
  log_destination      = var.flow_log_destination_type == "s3" ? aws_s3_bucket.log_bucket.arn : null
  iam_role_arn         = aws_iam_role.flowlog_role.arn
}
