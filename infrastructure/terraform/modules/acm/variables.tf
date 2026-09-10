variable "domain_name" {
  description = "Domínio principal do certificado"
  type        = string
  default     = "cloudlab.example.com"
}

variable "subject_alternative_names" {
  description = "Domínios alternativos (SANs)"
  type        = list(string)
  default     = ["*.cloudlab.example.com"]
}

variable "hosted_zone_id" {
  description = "ID da Hosted Zone no Route53 para validação DNS"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
