output "repository_urls" {
  description = "URLs dos repositórios ECR"
  value       = { for k, v in aws_ecr_repository.this : k => v.repository_url }
}

output "repository_arns" {
  description = "ARNs dos repositórios ECR"
  value       = { for k, v in aws_ecr_repository.this : k => v.arn }
}

output "registry_id" {
  description = "ID do registry ECR (AWS Account ID)"
  value       = values(aws_ecr_repository.this)[0].registry_id
}
