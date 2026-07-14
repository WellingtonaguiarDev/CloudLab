resource "aws_db_parameter_group" "this" {

  name = "${var.identifier}-mysql"
  family = "mysql8.4"


  parameter {

    name = "character_set_server"
    value = "utf8mb4"

  }


  parameter {

    name = "character_set_client"
    value = "utf8mb4"

  }


  tags = merge(
    var.tags,
    {
      Name = "${var.identifier}-parameter"
    }
  )
}