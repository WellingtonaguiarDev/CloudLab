resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name               = "${var.network.name}-IG"
    EnvName            = var.network.name
    TerraformWorkspace = "${var.network.name}-${var.network.region}-default"
  }
}


