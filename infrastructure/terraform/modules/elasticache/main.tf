resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.cluster_id}-subnet-group"
  subnet_ids = var.network.private_subnet_ids

  tags = merge(var.tags, { Name = "${var.cluster_id}-subnet-group" })
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = var.cluster_id
  description          = "Redis cluster para o CloudLab"

  node_type            = var.node_type
  num_cache_clusters   = var.num_cache_nodes
  engine_version       = var.engine_version
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [var.security_group_id]

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                 = var.kms_key_arn

  automatic_failover_enabled = false

  apply_immediately = false

  tags = merge(var.tags, { Name = var.cluster_id })
}
