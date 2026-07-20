resource "aws_ecs_service" "this" {

  name = var.service_name
  cluster = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count = 1

  launch_type = "FARGATE"

  network_configuration {

    subnets = var.network.private_subnet_ids

    security_groups = [
      aws_security_group.this.id
    ]

    assign_public_ip = false
  }
}