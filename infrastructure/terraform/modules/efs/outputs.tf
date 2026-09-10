output "id" {
  description = "ID do EFS File System"
  value       = aws_efs_file_system.this.id
}

output "arn" {
  description = "ARN do EFS File System"
  value       = aws_efs_file_system.this.arn
}

output "dns_name" {
  description = "DNS name do EFS"
  value       = aws_efs_file_system.this.dns_name
}

output "access_point_id" {
  description = "ID do Access Point da aplicação"
  value       = aws_efs_access_point.app.id
}

output "access_point_arn" {
  description = "ARN do Access Point da aplicação"
  value       = aws_efs_access_point.app.arn
}
