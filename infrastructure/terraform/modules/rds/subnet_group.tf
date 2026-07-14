resource "aws_db_subnet_group" "this" {

  name = "${var.identifier}-subnet"
  subnet_ids = var.network.private_subnet_ids


  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-subnet"
    }
  )
}