output "arn" {
  description = "ARN do ALB"
  value       = aws_lb.this.arn
}

output "dns_name" {
  description = "DNS name do ALB"
  value       = aws_lb.this.dns_name
}

output "zone_id" {
  description = "Zone ID do ALB (para records ALIAS no Route53)"
  value       = aws_lb.this.zone_id
}

output "https_listener_arn" {
  description = "ARN do listener HTTPS"
  value       = aws_lb_listener.https.arn
}

output "target_group_arns" {
  description = "ARNs dos target groups"
  value       = { for k, v in aws_lb_target_group.this : k => v.arn }
}
