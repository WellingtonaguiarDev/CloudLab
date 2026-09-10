variable "oidc_provider_arn" {
  description = "ARN do OIDC provider do EKS (para IRSA)"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL do OIDC provider do EKS (para IRSA)"
  type        = string
}

variable "irsa_roles" {
  description = "Mapa de roles IRSA a serem criadas"
  type = map(object({
    namespace       = string
    service_account = string
    policy_arns     = list(string)
  }))
  default = {}
}

variable "tags" {
  type    = map(string)
  default = {}
}
