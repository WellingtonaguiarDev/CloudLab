variable "name" {
  description = "Nome do EFS"
  type        = string
  default     = "cloudlab-efs"
}

variable "network" {
  description = "Network information from VPC module"
  type = object({
    id                 = string
    private_subnet_ids = list(string)
  })
}

variable "security_group_id" {
  description = "Security Group ID do EFS"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN da KMS key para criptografia do EFS"
  type        = string
  default     = null
}

variable "transition_to_ia" {
  description = "Período para mover arquivos para Infrequent Access"
  type        = string
  default     = "AFTER_30_DAYS"
}

variable "tags" {
  type    = map(string)
  default = {}
}
