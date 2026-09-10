variable "log_retention_days" {
  description = "Dias de retenção dos log groups"
  type        = number
  default     = 30
}

variable "kms_key_arn" {
  description = "ARN da KMS key para criptografia dos logs"
  type        = string
  default     = null
}

variable "rds_identifier" {
  description = "Identifier do RDS para alarmes"
  type        = string
  default     = "cloudlab-mysql"
}

variable "ecs_cluster_name" {
  description = "Nome do cluster ECS para alarmes"
  type        = string
  default     = "cloudlab-ecs"
}

variable "alb_arn_suffix" {
  description = "ARN suffix do ALB para alarmes"
  type        = string
  default     = ""
}

variable "alarm_actions" {
  description = "Lista de ARNs SNS para notificações de alarme"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
