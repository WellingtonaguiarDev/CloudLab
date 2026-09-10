resource "aws_efs_file_system" "this" {
  encrypted  = true
  kms_key_id = var.kms_key_arn

  lifecycle_policy {
    transition_to_ia = var.transition_to_ia
  }

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  tags = merge(var.tags, { Name = var.name })
}

resource "aws_efs_mount_target" "this" {
  for_each = toset(var.network.private_subnet_ids)

  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = [var.security_group_id]
}

resource "aws_efs_access_point" "app" {
  file_system_id = aws_efs_file_system.this.id

  posix_user {
    uid = 1000
    gid = 1000
  }

  root_directory {
    path = "/app"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "755"
    }
  }

  tags = merge(var.tags, { Name = "${var.name}-app" })
}
