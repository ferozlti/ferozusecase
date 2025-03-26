# CodeBuild Project with webhook integration
resource "aws_codebuild_project" "app_build" {
  name         = "${var.app_name}-build"
  service_role = aws_iam_role.codebuild_role.arn
  
  artifacts {
    type = "NO_ARTIFACTS"
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
    
    # GitHub authentication - using source credential resource instead of inline
    # auth {
    #   type     = "OAUTH"
    #   resource = var.github_token
    # }
    
    buildspec = "buildspec.yml"
    report_build_status = true
  }
}
 
# Source credentials for GitHub - separate resource
resource "aws_codebuild_source_credential" "github_credential" {
  auth_type   = "PERSONAL_ACCESS_TOKEN"
  server_type = "GITHUB"
  token       = var.github_token
}
 
# Webhook configuration for GitHub - with correct pattern for master branch
resource "aws_codebuild_webhook" "github_webhook" {
  project_name = aws_codebuild_project.app_build.name
  
  # Explicitly set build type to BUILD
  build_type = "BUILD"
  
  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PUSH"
    }
    
    # Make sure this matches your actual branch name (master)
    filter {
      type    = "HEAD_REF"
      pattern = "refs/heads/master"  # Use full reference format
    }
  }
}
