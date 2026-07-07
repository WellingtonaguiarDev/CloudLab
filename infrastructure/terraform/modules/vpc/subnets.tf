resource "aws_subnet" "this" {
  for_each = { for s in var.subnets : s.name => s }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.map_public_ip_on_launch

  tags = {
    Name                = each.key
    MapPublicIpOnLaunch = tostring(each.value.map_public_ip_on_launch)
    EnvName             = var.network.name
    TerraformWorkspace  = "${var.network.name}-${var.network.region}-default"
  }
}
