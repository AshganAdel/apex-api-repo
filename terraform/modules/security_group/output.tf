output "sg_id" {
  value = aws_security_group.my-sg.id
}
output "eks_nodes_sg_id" {
  value = aws_security_group.node_sg.id
}
output "rds_sg_id" {
  value = aws_security_group.rds_sg.id
}