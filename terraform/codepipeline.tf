# CodePipeline with GitHub integration (v1)
resource "aws_codepipeline" "app_pipeline" {
  name     = "${var.app_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  
  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }
  
  stage {
    name = "Source"
    
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
      
      configuration = {
        Owner       = var.github_owner
        Repo        = var.github_repo
        Branch      = "main"
        OAuthToken  = var.github_token
      }
    }
  }
  
  stage {
    name = "Build"
    
    action {
      name             = "BuildImage"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      
      configuration = {
        ProjectName = aws_codebuild_project.app_build.name
      }
    }
  }
  
  stage {
    name = "Deploy"
    
    action {
      name            = "DeployToECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]
      
      configuration = {
        ClusterName = aws_ecs_cluster.app_cluster.name
        ServiceName = aws_ecs_service.app_service.name
        FileName    = "imageDefinition.json"
      }
    }
  }
  
  # This will silence the GitHub v1 provider deprecation warning
  lifecycle {
    ignore_changes = [
      stage[0].action[0].configuration["OAuthToken"]
    ]
  }
}
