variable "domain_name" {
  description = "Domínio principal da hosted zone"
  type        = string
  default     = "cloudlab.example.com"
}

variable "alb_dns_name" {
  description = "DNS name do ALB para criação dos records"
  type        = string
  default     = ""
}

variable "alb_zone_id" {
  description = "Zone ID do ALB para criação dos records ALIAS"
  type        = string
  default     = ""
}

variable "records" {
  description = "Records DNS adicionais"
  type = map(object({
    type    = string
    ttl     = optional(number, 300)
    records = optional(list(string), [])
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = bool
    }), null)
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
