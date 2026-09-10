output "log_group_arns" {
  description = "ARNs dos log groups"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.arn }
}

output "log_group_names" {
  description = "Nomes dos log groups"
  value       = { for k, v in aws_cloudwatch_log_group.this : k => v.name }
}

output "dashboard_arn" {
  description = "ARN do dashboard CloudWatch"
  value       = aws_cloudwatch_dashboard.this.dashboard_arn
}
