variable "name" {
  description = "Nome do ALB"
  type        = string
  default     = "cloudlab-alb"
}

variable "network" {
  description = "Network information from VPC module"
  type = object({
    id                = string
    public_subnet_ids = list(string)
  })
}

variable "security_group_id" {
  description = "Security Group ID do ALB"
  type        = string
}

variable "certificate_arn" {
  description = "ARN do certificado ACM para HTTPS"
  type        = string
}

variable "target_groups" {
  description = "Mapa de target groups a serem criados"
  type = map(object({
    port     = number
    protocol = string
    health_check_path = optional(string, "/")
  }))
  default = {
    backend = {
      port              = 8080
      protocol          = "HTTP"
      health_check_path = "/health"
    }
    frontend = {
      port              = 80
      protocol          = "HTTP"
      health_check_path = "/"
    }
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
