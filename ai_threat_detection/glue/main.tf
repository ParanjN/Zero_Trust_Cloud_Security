# AWS Glue Resources for AI Threat Detection

resource "aws_glue_catalog_database" "threat_detection_db" {
  name = "${var.project}_database"
}

resource "aws_glue_crawler" "log_crawler" {
  database_name = aws_glue_catalog_database.threat_detection_db.name
  name          = "${var.project}-log-crawler"
  role          = aws_iam_role.glue_role.arn

  s3_target {
    path = "s3://${var.data_lake_bucket}/logs/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }

  schedule = "cron(0 */6 * * ? *)"

  configuration = jsonencode({
    Version = 1.0
    CrawlerOutput = {
      Partitions = { AddOrUpdateBehavior = "InheritFromTable" }
    }
  })

  tags = {
    Name    = "${var.project}-log-crawler"
    Project = var.project
  }
}