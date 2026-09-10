variable "name" {
  description = "Nome do Web ACL"
  type        = string
  default     = "cloudlab-waf"
}

variable "alb_arn" {
  description = "ARN do ALB para associar o WAF"
  type        = string
}

variable "allowed_countries" {
  description = "Lista de países permitidos (ISO 3166-1 alpha-2). Vazio = sem restrição geográfica"
  type        = list(string)
  default     = []
}

variable "rate_limit" {
  description = "Limite de requisições por IP a cada 5 minutos"
  type        = number
  default     = 2000
}

variable "tags" {
  type    = map(string)
  default = {}
}
