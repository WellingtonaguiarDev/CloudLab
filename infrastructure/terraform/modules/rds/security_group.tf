resource "aws_security_group" "this" {

  name = "${var.identifier}-rds"
  description = "Security group for MySQL RDS"
  vpc_id = var.network.id


  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-rds"
    }
  )
}


resource "aws_vpc_security_group_ingress_rule" "mysql" {

  security_group_id = aws_security_group.this.id
  cidr_ipv4 = var.network.cidr_block
  from_port = 3306
  to_port = 3306
  ip_protocol = "tcp"
}


resource "aws_vpc_security_group_egress_rule" "all" {

  security_group_id = aws_security_group.this.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}