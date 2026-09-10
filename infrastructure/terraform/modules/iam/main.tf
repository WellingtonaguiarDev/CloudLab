data "aws_caller_identity" "current" {}

locals {
  oidc_subject = replace(var.oidc_provider_url, "https://", "")
}

############################################
# IRSA Roles
############################################

resource "aws_iam_role" "irsa" {
  for_each = var.irsa_roles

  name = "cloudlab-irsa-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${local.oidc_subject}:sub" = "system:serviceaccount:${each.value.namespace}:${each.value.service_account}"
            "${local.oidc_subject}:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "cloudlab-irsa-${each.key}"
  })
}

resource "aws_iam_role_policy_attachment" "irsa" {
  for_each = {
    for pair in flatten([
      for role_key, role in var.irsa_roles : [
        for policy_arn in role.policy_arns : {
          key        = "${role_key}-${index(role.policy_arns, policy_arn)}"
          role       = role_key
          policy_arn = policy_arn
        }
      ]
    ]) : pair.key => pair
  }

  role       = aws_iam_role.irsa[each.value.role].name
  policy_arn = each.value.policy_arn
}

############################################
# Custom Policies
############################################

resource "aws_iam_policy" "s3_readwrite" {
  name        = "cloudlab-s3-readwrite"
  description = "Permite leitura e escrita no bucket cloudlab-storage"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::cloudlab-storage",
          "arn:aws:s3:::cloudlab-storage/*"
        ]
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "secrets_readonly" {
  name        = "cloudlab-secrets-readonly"
  description = "Permite leitura dos secrets do Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:cloudlab/*"
      }
    ]
  })

  tags = var.tags
}
