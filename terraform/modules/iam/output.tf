output "eks_role_arn" {
  value = aws_iam_role.cluster.arn
}
output "node_role_arn" {
  value = aws_iam_role.node.arn
}
output "pod_identity_role_arn" {
  value = aws_iam_role.pod_identity_role.arn
}