variable "network" {
  description = "Network information from VPC module."

  type = object({
    id                         = string
    arn                        = string
    cidr_block                 = string

    public_subnet_ids          = list(string)
    private_subnet_ids         = list(string)

    public_route_table_id      = string
    private_route_table_id     = string

    internet_gateway_id        = string

    nat_gateway_id             = string
    nat_gateway_public_ip      = string
    nat_gateway_allocation_id  = string

    public_network_acl_id      = string
    private_network_acl_id     = string
  })
}


variable "identifier" {
  description = "RDS identifier."
  type        = string
  default     = "cloudlab-mysql"
}


variable "database_name" {
  description = "Database name."
  type        = string
  default     = "cloudlab"
}


variable "username" {
  description = "Master username."
  type        = string
  default     = "admin"
}


variable "engine" {
  description = "Database engine."
  type        = string
  default     = "mysql"
}


variable "engine_version" {
  description = "MySQL version."
  type        = string
  default     = "8.4"
}


variable "instance_class" {
  description = "RDS instance type."
  type        = string
  default     = "db.t3.micro"
}


variable "allocated_storage" {
  description = "Initial storage size in GB."
  type        = number
  default     = 20
}


variable "max_allocated_storage" {
  description = "Maximum storage autoscaling."
  type        = number
  default     = 100
}


variable "multi_az" {
  description = "Enable Multi AZ."
  type        = bool
  default     = false
}


variable "backup_retention_period" {
  description = "Backup retention days."
  type        = number
  default     = 7
}


variable "deletion_protection" {
  description = "Enable deletion protection."
  type        = bool
  default     = false
}


variable "storage_encrypted" {
  description = "Enable storage encryption."
  type        = bool
  default     = true
}


variable "publicly_accessible" {
  description = "Allow public access."
  type        = bool
  default     = false
}


variable "skip_final_snapshot" {
  description = "Skip final snapshot on destroy."
  type        = bool
  default     = true
}



variable "tags" {
  description = "Tags."

  type = map(string)

  default = {}
}