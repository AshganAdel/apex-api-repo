output "eks_name" {
  value = aws_eks_cluster.eks.name
}

output "eks_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "eks_certificate_authority" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}