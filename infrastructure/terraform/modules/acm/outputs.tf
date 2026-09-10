output "certificate_arn" {
  description = "ARN do certificado ACM"
  value       = aws_acm_certificate_validation.this.certificate_arn
}

output "domain_name" {
  description = "Domínio principal do certificado"
  value       = aws_acm_certificate.this.domain_name
}
