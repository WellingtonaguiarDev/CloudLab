resource "aws_security_group" "this" {

  name        = "${var.service_name}-ecs"
  description = "ECS Fargate Security Group"

  vpc_id = var.network.id

  tags = merge(
    var.tags,
    {
      Name = "${var.service_name}-ecs"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "http" {

  security_group_id = aws_security_group.this.id

  cidr_ipv4 = "0.0.0.0/0"

  from_port = var.container_port
  to_port   = var.container_port

  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {

  security_group_id = aws_security_group.this.id

  cidr_ipv4 = "0.0.0.0/0"

  ip_protocol = "-1"
}