############################################
# Log Groups
############################################

locals {
  log_groups = {
    ecs         = "/cloudlab/ecs"
    eks         = "/cloudlab/eks"
    rds         = "/cloudlab/rds"
    application = "/cloudlab/application"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  for_each = local.log_groups

  name              = each.value
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn

  tags = merge(var.tags, { Name = each.value })
}

############################################
# Alarmes RDS
############################################

resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "cloudlab-rds-cpu-high"
  alarm_description   = "CPU do RDS acima de 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }

  alarm_actions = var.alarm_actions
  tags          = var.tags
}

resource "aws_cloudwatch_metric_alarm" "rds_storage" {
  alarm_name          = "cloudlab-rds-storage-low"
  alarm_description   = "Storage livre do RDS abaixo de 5GB"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 5368709120 # 5GB em bytes

  dimensions = {
    DBInstanceIdentifier = var.rds_identifier
  }

  alarm_actions = var.alarm_actions
  tags          = var.tags
}

############################################
# Alarmes ECS
############################################

resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name          = "cloudlab-ecs-cpu-high"
  alarm_description   = "CPU do ECS acima de 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    ClusterName = var.ecs_cluster_name
  }

  alarm_actions = var.alarm_actions
  tags          = var.tags
}

############################################
# Alarmes ALB
############################################

resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  count = var.alb_arn_suffix != "" ? 1 : 0

  alarm_name          = "cloudlab-alb-5xx-high"
  alarm_description   = "Taxa de erros 5xx do ALB acima de 10"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  alarm_actions = var.alarm_actions
  tags          = var.tags
}

############################################
# Dashboard
############################################

resource "aws_cloudwatch_dashboard" "this" {
  dashboard_name = "cloudlab"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          title  = "RDS CPU"
          period = 300
          metrics = [["AWS/RDS", "CPUUtilization", "DBInstanceIdentifier", var.rds_identifier]]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ECS CPU"
          period = 300
          metrics = [["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name]]
        }
      },
      {
        type = "metric"
        properties = {
          title  = "ECS Memory"
          period = 300
          metrics = [["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name]]
        }
      }
    ]
  })
}
