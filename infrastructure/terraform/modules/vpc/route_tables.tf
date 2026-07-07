locals {
  public_subnets = {
    for k, s in aws_subnet.this :
    k => s if s.map_public_ip_on_launch
  }

  private_subnets = {
    for k, s in aws_subnet.this :
    k => s if !s.map_public_ip_on_launch
  }
}


# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.network.name}-RouteTable-Public"
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = local.public_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.network.name}-RouteTable-Private"
  }
}

resource "aws_route_table_association" "private_assoc" {
  for_each = local.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
