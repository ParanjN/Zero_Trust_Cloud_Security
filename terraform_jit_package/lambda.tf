# JIT Create Lambda Function
data "archive_file" "jit_create" {
  type        = "zip"
  source_file = "${path.module}/lambda/jit_create_src/jit_create.py"
  output_path = "${path.module}/lambda/jit_create.zip"
}

resource "aws_lambda_function" "jit_create" {
  filename         = data.archive_file.jit_create.output_path
  function_name    = "jit-access-create"
  role            = aws_iam_role.lambda_role.arn
  handler         = "jit_create.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30

  environment {
    variables = {
      IDENTITY_STORE_ID = var.identity_store_id
      SSO_INSTANCE_ARN = var.identity_center_instance_arn
    }
  }
}

# JIT Cleanup Lambda Function
data "archive_file" "jit_cleanup" {
  type        = "zip"
  source_file = "${path.module}/lambda/jit_cleanup_src/jit_cleanup.py"
  output_path = "${path.module}/lambda/jit_cleanup.zip"
}

resource "aws_lambda_function" "jit_cleanup" {
  filename         = data.archive_file.jit_cleanup.output_path
  function_name    = "jit-access-cleanup"
  role            = aws_iam_role.lambda_role.arn
  handler         = "jit_cleanup.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30

  environment {
    variables = {
      IDENTITY_STORE_ID = var.identity_store_id
      SSO_INSTANCE_ARN = var.identity_center_instance_arn
    }
  }
}

# IAM role for Lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "jit-access-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}