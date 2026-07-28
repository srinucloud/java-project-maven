##################################
# EKS Cluster
##################################

resource "aws_eks_cluster" "eks" {

  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {

    subnet_ids = data.aws_subnets.default.ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy
  ]
}

##################################
# Managed Node Group
##################################

resource "aws_eks_node_group" "nodes" {

  cluster_name = aws_eks_cluster.eks.name

  node_group_name = var.node_group_name

  node_role_arn = aws_iam_role.eks_node_role.arn

  subnet_ids = data.aws_subnets.default.ids

  instance_types = [
    var.instance_type
  ]

  scaling_config {

    desired_size = 2

    min_size = 1

    max_size = 3
  }

  capacity_type = "ON_DEMAND"

  depends_on = [

    aws_iam_role_policy_attachment.worker_policy,

    aws_iam_role_policy_attachment.cni_policy,

    aws_iam_role_policy_attachment.ecr_policy
  ]
}