output "key_ids" {
  description = "IDs das chaves KMS"
  value       = { for k, v in aws_kms_key.this : k => v.key_id }
}

output "key_arns" {
  description = "ARNs das chaves KMS"
  value       = { for k, v in aws_kms_key.this : k => v.arn }
}

output "aliases" {
  description = "Aliases das chaves KMS"
  value       = { for k, v in aws_kms_alias.this : k => v.name }
}
