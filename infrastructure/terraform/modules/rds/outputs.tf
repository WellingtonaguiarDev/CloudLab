output "id" {
  description = "RDS instance ID."
  value = aws_db_instance.this.id
}


output "arn" {
  description = "RDS instance ARN."
  value = aws_db_instance.this.arn
}


output "endpoint" {
  description = "RDS connection endpoint."
  value = aws_db_instance.this.endpoint
}


output "address" {
  description = "RDS hostname."
  value = aws_db_instance.this.address
}


output "port" {
  description = "RDS port."
  value = aws_db_instance.this.port
}


output "database_name" {
  description = "Database name."
  value = var.database_name
}


output "username" {
  description = "Database master username."
  value = var.username
}


output "security_group_id" {
  description = "RDS security group ID."
  value = aws_security_group.this.id
}


output "subnet_group_name" {
  description = "RDS subnet group name."
  value = aws_db_subnet_group.this.name
}


output "parameter_group_name" {
  description = "RDS parameter group name."
  value = aws_db_parameter_group.this.name
}


output "instance_class" {
  description = "RDS instance class."
  value = var.instance_class
}