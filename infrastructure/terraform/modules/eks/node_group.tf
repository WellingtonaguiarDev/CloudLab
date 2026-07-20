resource "aws_eks_node_group" "this" {

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-default"

  node_role_arn = aws_iam_role.nodegroup.arn

  subnet_ids = var.network.private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  instance_types = var.instance_types

  depends_on = [
    aws_iam_role_policy_attachment.worker_nodes,
    aws_iam_role_policy_attachment.cni,
    aws_iam_role_policy_attachment.ecr
  ]

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-default"
    }
  )
}