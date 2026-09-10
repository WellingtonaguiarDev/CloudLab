variable "cluster_id" {
  description = "ID do cluster ElastiCache"
  type        = string
  default     = "cloudlab-redis"
}

variable "network" {
  description = "Network information from VPC module"
  type = object({
    id                 = string
    private_subnet_ids = list(string)
  })
}

variable "security_group_id" {
  description = "Security Group ID do ElastiCache"
  type        = string
}

variable "node_type" {
  description = "Tipo do nó ElastiCache"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "Número de nós do cluster"
  type        = number
  default     = 1
}

variable "engine_version" {
  description = "Versão do Redis"
  type        = string
  default     = "7.1"
}

variable "kms_key_arn" {
  description = "ARN da KMS key para criptografia"
  type        = string
  default     = null
}

variable "tags" {
  type    = map(string)
  default = {}
}
