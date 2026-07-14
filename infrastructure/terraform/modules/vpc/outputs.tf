############################################
# VPC
############################################

output "id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "arn" {
  description = "VPC ARN."
  value       = aws_vpc.this.arn
}

output "cidr_block" {
  description = "VPC CIDR Block."
  value       = aws_vpc.this.cidr_block
}

############################################
# Internet Gateway
############################################

output "internet_gateway_id" {
  description = "Internet Gateway ID."
  value       = aws_internet_gateway.this.id
}

############################################
# NAT Gateway
############################################

output "nat_gateway_id" {
  description = "NAT Gateway ID."
  value       = aws_nat_gateway.this.id
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway Public IP."
  value       = aws_eip.nat.public_ip
}

output "nat_gateway_allocation_id" {
  description = "Elastic IP Allocation ID."
  value       = aws_eip.nat.allocation_id
}

############################################
# Route Tables
############################################

output "public_route_table_id" {
  description = "Public Route Table ID."
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "Private Route Table ID."
  value       = aws_route_table.private.id
}

############################################
# Network ACLs
############################################

output "public_network_acl_id" {
  description = "Public Network ACL ID."
  value       = aws_network_acl.public.id
}

output "private_network_acl_id" {
  description = "Private Network ACL ID."
  value       = aws_network_acl.private.id
}

############################################
# Public Subnets
############################################

output "public_subnet_ids" {
  description = "Public Subnet IDs."
  value = [
    for subnet in values(local.public_subnets) :
    subnet.id
  ]
}

output "public_subnet_arns" {
  description = "Public Subnet ARNs."
  value = [
    for subnet in values(local.public_subnets) :
    subnet.arn
  ]
}

############################################
# Private Subnets
############################################

output "private_subnet_ids" {
  description = "Private Subnet IDs."
  value = [
    for subnet in values(local.private_subnets) :
    subnet.id
  ]
}

output "private_subnet_arns" {
  description = "Private Subnet ARNs."
  value = [
    for subnet in values(local.private_subnets) :
    subnet.arn
  ]
}

############################################
# Complete Network Object
############################################

output "network" {
  description = "Complete network information."

  value = {
    id                        = aws_vpc.this.id
    arn                       = aws_vpc.this.arn
    cidr_block                = aws_vpc.this.cidr_block

    public_subnet_ids = [
      for subnet in values(local.public_subnets) :
      subnet.id
    ]

    private_subnet_ids = [
      for subnet in values(local.private_subnets) :
      subnet.id
    ]

    public_route_table_id     = aws_route_table.public.id
    private_route_table_id    = aws_route_table.private.id

    internet_gateway_id       = aws_internet_gateway.this.id

    nat_gateway_id            = aws_nat_gateway.this.id
    nat_gateway_public_ip     = aws_eip.nat.public_ip
    nat_gateway_allocation_id = aws_eip.nat.allocation_id

    public_network_acl_id     = aws_network_acl.public.id
    private_network_acl_id    = aws_network_acl.private.id
  }
}