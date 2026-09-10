output "id" {
  description = "ID do replication group"
  value       = aws_elasticache_replication_group.this.id
}

output "primary_endpoint" {
  description = "Endpoint primário do Redis"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint" {
  description = "Endpoint de leitura do Redis"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "Porta do Redis"
  value       = aws_elasticache_replication_group.this.port
}
