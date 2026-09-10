output "hosted_zone_id" {
  description = "ID da Hosted Zone"
  value       = aws_route53_zone.this.zone_id
}

output "hosted_zone_arn" {
  description = "ARN da Hosted Zone"
  value       = aws_route53_zone.this.arn
}

output "name_servers" {
  description = "Name servers da Hosted Zone (configurar no registrador de domínio)"
  value       = aws_route53_zone.this.name_servers
}

output "domain_name" {
  description = "Domínio da Hosted Zone"
  value       = aws_route53_zone.this.name
}
