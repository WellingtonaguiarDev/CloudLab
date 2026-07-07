# EIP para NAT
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.network.name}-NAT-EIP" }
}

# NAT Gateway
resource "aws_nat_gateway" "this" {
  subnet_id     = aws_subnet.this["PROD-Subnet-Public-A"].id
  allocation_id = aws_eip.nat.id

  tags = {
    Name               = "${var.network.name}-NATGW-0"
    EnvName            = var.network.name
    TerraformWorkspace = "${var.network.name}-${var.network.region}-default"
  }
}