data "aws_caller_identity" "current" {}

resource "aws_kms_key" "this" {
  for_each = var.keys

  description             = each.value.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "cloudlab-kms-${each.key}"
  })
}

resource "aws_kms_alias" "this" {
  for_each = aws_kms_key.this

  name          = "alias/cloudlab-${each.key}"
  target_key_id = each.value.key_id
}
