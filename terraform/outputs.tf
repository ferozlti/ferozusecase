output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.app_repo.repository_url
}
/*
output "codebuild_webhook_url" {
  description = "GitHub webhook URL"
  value       = aws_codebuild_webhook.github_webhook.url
  sensitive   = true
}
*/
output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.app_service.name
}

output "webhook_instructions" {
  description = "Instructions to configure the webhook in GitHub"
  value       = "Go to your GitHub repository > Settings > Webhooks > Add webhook, and paste the webhook URL."
}
