variable "region" {}
variable "vpc_cidr" {}
variable "private_subnets_cidr" {}
variable "public_subnets_cidr" {}
variable "private_subnets_names" {}
variable "public_subnets_names" {}
variable "ec2_nodes_type" {
    type = list(string)
}
variable "eks_node_group_name" {}
variable "eks_cluster_name" {}
variable "vpc_name" {}
variable "igw_name" {}
variable "ssh_key_name" {}
variable "ec2_names" {}
variable "ec2_type" {}
variable "ami" {}
variable "ecr_repo" {}
variable "eks_role_name"{}
variable "eks_node_role_name" {}
variable "eks_cluster_policies_arns" {
    type = list(string)
}
variable "node_policies" {
    type = list(string)
}
variable "pod_identity_role_name" {}
variable "pod_policy_name" {}
variable "pod_policy_actions_to_allow" {
    type = list(string)
}