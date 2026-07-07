# Network ACL para Subnets Públicas
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.this.id

  # Inbound Rules
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  # Ephemeral ports para respostas
  ingress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound Rules
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.network.cidr_block
    from_port  = 0
    to_port    = 65535
  }

  # Ephemeral ports para respostas
  egress {
    protocol   = "tcp"
    rule_no    = 130
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  tags = {
    Name               = "${var.network.name}-NACL-Public"
    EnvName            = var.network.name
    TerraformWorkspace = "${var.network.name}-${var.network.region}-default"
  }
}

# Network ACL para Subnets Privadas
resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.this.id

  # Inbound Rules - apenas tráfego interno da VPC
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.network.cidr_block
    from_port  = 0
    to_port    = 65535
  }

  # Ephemeral ports para respostas da internet (via NAT)
  ingress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  # Outbound Rules
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  egress {
    protocol   = "tcp"
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  egress {
    protocol   = "tcp"
    rule_no    = 120
    action     = "allow"
    cidr_block = var.network.cidr_block
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name               = "${var.network.name}-NACL-Private"
    EnvName            = var.network.name
    TerraformWorkspace = "${var.network.name}-${var.network.region}-default"
  }
}

# Associações das NACLs com as Subnets Públicas
resource "aws_network_acl_association" "public" {
  for_each = local.public_subnets

  network_acl_id = aws_network_acl.public.id
  subnet_id      = each.value.id
}

# Associações das NACLs com as Subnets Privadas
resource "aws_network_acl_association" "private" {
  for_each = local.private_subnets

  network_acl_id = aws_network_acl.private.id
  subnet_id      = each.value.id
}