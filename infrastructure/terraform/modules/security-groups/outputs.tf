output "alb_security_group_id" {
  description = "Security Group ID do ALB"
  value       = aws_security_group.alb.id
}

output "elasticache_security_group_id" {
  description = "Security Group ID do ElastiCache"
  value       = aws_security_group.elasticache.id
}

output "efs_security_group_id" {
  description = "Security Group ID do EFS"
  value       = aws_security_group.efs.id
}
