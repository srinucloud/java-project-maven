output "cluster_name" {

  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {

  value = aws_eks_cluster.eks.endpoint
}

output "cluster_version" {

  value = aws_eks_cluster.eks.version
}