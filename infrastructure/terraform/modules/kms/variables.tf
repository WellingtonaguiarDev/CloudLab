variable "keys" {
  description = "Mapa de chaves KMS a serem criadas"
  type = map(object({
    description = string
  }))
  default = {
    rds = {
      description = "KMS key para criptografia do RDS"
    }
    s3 = {
      description = "KMS key para criptografia do S3"
    }
    secrets = {
      description = "KMS key para criptografia do Secrets Manager"
    }
  }
}

variable "deletion_window_in_days" {
  description = "Janela de exclusão da chave KMS em dias"
  type        = number
  default     = 7
}

variable "enable_key_rotation" {
  description = "Habilita rotação automática anual da chave"
  type        = bool
  default     = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
