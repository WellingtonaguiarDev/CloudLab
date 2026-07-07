resource "aws_network" "this" {
  cidr_block           = var.network.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name               = "${var.network.name}"
    EnvName            = var.network.name
    TerraformWorkspace = "${var.network.name}-${var.network.region}-default"
  }
}
