variable "repositories" {
  description = "Lista de repositórios ECR a serem criados"
  type        = list(string)
  default     = ["backend", "frontend"]
}

variable "image_tag_mutability" {
  description = "Mutabilidade das tags de imagem"
  type        = string
  default     = "IMMUTABLE"
}

variable "scan_on_push" {
  description = "Habilita scan de vulnerabilidades no push"
  type        = bool
  default     = true
}

variable "lifecycle_policy_count" {
  description = "Número máximo de imagens não-tagged a manter"
  type        = number
  default     = 10
}

variable "tags" {
  type    = map(string)
  default = {}
}
