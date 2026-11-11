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
variable "resource_policy_allow_on_arn" {
  
}