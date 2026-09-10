output "irsa_role_arns" {
  description = "ARNs das roles IRSA criadas"
  value       = { for k, v in aws_iam_role.irsa : k => v.arn }
}

output "s3_readwrite_policy_arn" {
  description = "ARN da policy de leitura/escrita no S3"
  value       = aws_iam_policy.s3_readwrite.arn
}

output "secrets_readonly_policy_arn" {
  description = "ARN da policy de leitura do Secrets Manager"
  value       = aws_iam_policy.secrets_readonly.arn
}
