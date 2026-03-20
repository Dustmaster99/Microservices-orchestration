output "repository_names" {
  description = "Nomes dos repositórios ECR criados"
  value       = { for k, v in aws_ecr_repository.repositories : k => v.name }
}

output "repository_urls" {
  description = "URLs dos repositórios ECR criados"
  value       = { for k, v in aws_ecr_repository.repositories : k => v.repository_url }
}

output "repository_arns" {
  description = "ARNs dos repositórios ECR criados"
  value       = { for k, v in aws_ecr_repository.repositories : k => v.arn }
}