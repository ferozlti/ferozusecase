# CodeBuild Project for GitHub webhook integration
resource "aws_codebuild_project" "app_build" {
  name         = "${var.app_name}-build"
  service_role = aws_iam_role.codebuild_role.arn
  
  # Explicitly set all artifact properties
  artifacts {
    type                = "NO_ARTIFACTS"
    name                = null
    namespace_type      = null
    packaging           = null
    path                = null
    encryption_disabled = null
  }
  
  environment {
    type                        = "LINUX_CONTAINER"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode             = true
    
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }
    
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = var.aws_account_id
    }
    
    environment_variable {
      name  = "ECR_REPOSITORY_NAME"
      value = aws_ecr_repository.app_repo.name
    }
  }
  
  source {
    type            = "GITHUB"
    location        = "https://github.com/${var.github_owner}/${var.github_repo}.git"
    git_clone_depth = 1
    buildspec       = "buildspec.yml"
    # No auth block here, using aws_codebuild_source_credential instead
  }
  
  # Force a full replacement instead of an update
  lifecycle {
    create_before_destroy = true
  }
}
 
# GitHub credentials resource
resource "aws_codebuild_source_credential" "github_credential" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_token
}
 
# WebHook for GitHub to trigger build
/*
resource "aws_codebuild_webhook" "github_webhook" {
  project_name = aws_codebuild_project.app_build.name
  
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
    
    filter {
      type    = "HEAD_REF"
      pattern = "main"
    }
  }
}
*/
