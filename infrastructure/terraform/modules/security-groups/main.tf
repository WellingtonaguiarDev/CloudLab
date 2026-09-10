############################################
# ALB Security Group
############################################

resource "aws_security_group" "alb" {
  name        = "cloudlab-alb"
  description = "Security Group do Application Load Balancer"
  vpc_id      = var.network.id

  tags = merge(var.tags, { Name = "cloudlab-alb" })
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_all" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

############################################
# ElastiCache Security Group
############################################

resource "aws_security_group" "elasticache" {
  name        = "cloudlab-elasticache"
  description = "Security Group do ElastiCache Redis"
  vpc_id      = var.network.id

  tags = merge(var.tags, { Name = "cloudlab-elasticache" })
}

resource "aws_vpc_security_group_ingress_rule" "elasticache_redis" {
  security_group_id = aws_security_group.elasticache.id
  cidr_ipv4         = var.network.cidr_block
  from_port         = 6379
  to_port           = 6379
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "elasticache_all" {
  security_group_id = aws_security_group.elasticache.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

############################################
# EFS Security Group
############################################

resource "aws_security_group" "efs" {
  name        = "cloudlab-efs"
  description = "Security Group do Elastic File System"
  vpc_id      = var.network.id

  tags = merge(var.tags, { Name = "cloudlab-efs" })
}

resource "aws_vpc_security_group_ingress_rule" "efs_nfs" {
  security_group_id = aws_security_group.efs.id
  cidr_ipv4         = var.network.cidr_block
  from_port         = 2049
  to_port           = 2049
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "efs_all" {
  security_group_id = aws_security_group.efs.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
