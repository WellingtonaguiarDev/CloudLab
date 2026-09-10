variable "secrets" {
  description = "Mapa de secrets a serem criados"
  type = map(object({
    description = string
    secret_data = map(string)
  }))
  default = {}
}

variable "kms_key_arn" {
  description = "ARN da KMS key para criptografia dos secrets"
  type        = string
  default     = null
}

variable "recovery_window_in_days" {
  description = "Janela de recuperação antes da exclusão definitiva"
  type        = number
  default     = 7
}

variable "tags" {
  type    = map(string)
  default = {}
}
