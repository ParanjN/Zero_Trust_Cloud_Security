# Ingest Lambda Function
data "archive_file" "ingest_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_ingest_src"
  output_path = "${path.module}/lambda_ingest_src/ingest_package.zip"
}

resource "aws_lambda_function" "ingest_lambda" {
  filename         = data.archive_file.ingest_zip.output_path
  function_name    = "${var.project_prefix}-ingest-lambda-${random_id.suffix.hex}"
  handler          = "ingest.handler"
  runtime          = "python3.9"
  role            = aws_iam_role.lambda_role.arn
  source_code_hash = data.archive_file.ingest_zip.output_base64sha256
  
  environment {
    variables = {
      BUCKET = aws_s3_bucket.findings_bucket.bucket
    }
  }
  
  timeout     = 30
  memory_size = 256
}

# Score Lambda Function
data "archive_file" "score_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_score_src"
  output_path = "${path.module}/lambda_score_src/score_package.zip"
}

resource "aws_lambda_function" "score_lambda" {
  filename         = data.archive_file.score_zip.output_path
  function_name    = "${var.project_prefix}-score-lambda-${random_id.suffix.hex}"
  handler          = "score.handler"
  runtime          = "python3.9"
  role            = aws_iam_role.lambda_role.arn
  source_code_hash = data.archive_file.score_zip.output_base64sha256
  
  environment {
    variables = {
      BUCKET = aws_s3_bucket.findings_bucket.bucket
      SAGEMAKER_ENDPOINT = var.sagemaker_endpoint_name
    }
  }
  
  timeout     = 30
  memory_size = 512
}

# Lambda Permissions
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingest_lambda.function_name
  principal     = "events.amazonaws.com"
}

resource "aws_lambda_permission" "allow_s3_notify" {
  statement_id  = "AllowS3InvokeScore"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.score_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.findings_bucket.arn
}

# S3 Event Notification
resource "aws_s3_bucket_notification" "raw_to_score" {
  bucket = aws_s3_bucket.findings_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.score_lambda.arn
    events             = ["s3:ObjectCreated:*"]
    filter_prefix      = "raw/"
    filter_suffix      = ".json"
  }

  depends_on = [aws_lambda_permission.allow_s3_notify]
}