output "secret_arns" {
  description = "ARNs dos secrets criados"
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.arn }
}

output "secret_ids" {
  description = "IDs dos secrets criados"
  value       = { for k, v in aws_secretsmanager_secret.this : k => v.id }
}
