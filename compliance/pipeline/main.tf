# CI/CD Pipeline with Compliance Checks

# CodePipeline for Infrastructure Deployment
resource "aws_codepipeline" "compliance_pipeline" {
  name     = "compliance-pipeline"
  role_arn = aws_iam_role.pipeline_role.arn

  artifact_store {
    location = var.artifacts_bucket
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = var.repository_name
        BranchName     = "main"
      }
    }
  }

  stage {
    name = "SecurityCheck"
    action {
      name            = "CfnNagScan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.cfn_nag.name
      }
    }

    action {
      name            = "CheckovScan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.checkov.name
      }
    }
  }

  stage {
    name = "ContainerScan"
    action {
      name            = "ECRImageScan"
      category        = "Test"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ProjectName = aws_codebuild_project.ecr_scan.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ActionMode    = "CREATE_UPDATE"
        StackName     = var.stack_name
        TemplatePath  = "source_output::template.yaml"
        Capabilities  = "CAPABILITY_IAM,CAPABILITY_NAMED_IAM"
      }
    }
  }
}

# CodeBuild Project for cfn-nag
resource "aws_codebuild_project" "cfn_nag" {
  name         = "cfn-nag-scan"
  description  = "Scan CloudFormation templates with cfn-nag"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspecs/cfn-nag-buildspec.yml")
  }
}

# CodeBuild Project for Checkov
resource "aws_codebuild_project" "checkov" {
  name         = "checkov-scan"
  description  = "Scan Infrastructure as Code with Checkov"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspecs/checkov-buildspec.yml")
  }
}

# CodeBuild Project for ECR Image Scanning
resource "aws_codebuild_project" "ecr_scan" {
  name         = "ecr-image-scan"
  description  = "Scan container images with Amazon ECR"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type         = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspecs/ecr-scan-buildspec.yml")
  }
}