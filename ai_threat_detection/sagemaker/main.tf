# SageMaker Resources for AI Threat Detection

resource "aws_sagemaker_notebook_instance" "threat_detection" {
  name                    = "${var.project}-notebook"
  role_arn               = aws_iam_role.sagemaker_role.arn
  instance_type          = var.sagemaker_instance_type
  volume_size            = 50
  direct_internet_access = "Disabled"

  tags = {
    Name    = "${var.project}-notebook"
    Project = var.project
  }
}

resource "aws_sagemaker_endpoint_configuration" "rcf_endpoint_config" {
  name = "${var.project}-rcf-endpoint-config"

  production_variants {
    variant_name           = "default"
    model_name            = aws_sagemaker_model.rcf_model.name
    instance_type         = var.sagemaker_instance_type
    initial_instance_count = var.sagemaker_instance_count
  }

  tags = {
    Name    = "${var.project}-rcf-endpoint-config"
    Project = var.project
  }
}

resource "aws_sagemaker_model" "rcf_model" {
  name               = "${var.project}-rcf-model"
  execution_role_arn = aws_iam_role.sagemaker_role.arn

  primary_container {
    image = var.sagemaker_rcf_image
  }

  tags = {
    Name    = "${var.project}-rcf-model"
    Project = var.project
  }
}

resource "aws_sagemaker_endpoint" "rcf_endpoint" {
  name                 = "${var.project}-rcf-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.rcf_endpoint_config.name

  tags = {
    Name    = "${var.project}-rcf-endpoint"
    Project = var.project
  }
}