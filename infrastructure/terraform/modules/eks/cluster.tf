resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn

  version = var.cluster_version

  vpc_config {
    subnet_ids = var.network.private_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]

  tags = merge(
    var.tags,
    {
      Name = var.cluster_name
    }
  )
}