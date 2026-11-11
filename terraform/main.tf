module "vpc" {
  source = "./modules/vpc"
  cidr_vpc = var.vpc_cidr
  cidr_private = var.private_subnets_cidr
  public_subnet_cidr  =  var.public_subnets_cidr
  name_private = var.private_subnets_names
  name_public =  var.public_subnets_names
  vpc_name   =  var.vpc_name
  igw = var.igw_name
}

module "ec2" {
  source = "./modules/ec2"
  subnet_id = module.vpc.public_subnet_id
  public_ip_or_not = true
  ami = var.ami
  volume_size = "30"
  key_name = var.ssh_key_name
  instance_type = var.ec2_type
  security_group_ids = [module.sg.sg_id]
  ec2_names = var.ec2_names
}

module "sg" {
  source = "./modules/security_group"
  vpc_id = module.vpc.vpc_id
  vpc_cidr = var.vpc_cidr
}

module "iam" {
  source = "./modules/iam"
  resource_policy_allow_on_arn = module.rds.rds_secret_arn
  eks_role_name = var.eks_role_name
  eks_node_role_name = var.eks_node_role_name
  pod_identity_role_name = var.pod_identity_role_name
  pod_policy_name = var.pod_policy_name
  pod_policy_actions_to_allow = var.pod_policy_actions_to_allow
  eks_cluster_policies_arns = var.eks_cluster_policies_arns
  node_policies = var.node_policies
}

module "eks" {
  source = "./modules/eks"
  eks_subnets_ids = module.vpc.private_subnet_id
  eks_nodes_subnets_ids =  module.vpc.private_subnet_id
  security_group_ids = [module.sg.sg_id]
  enable_private_access = true
  enable_public_access =  true
  nodes_ec2_type  = var.ec2_nodes_type
  node_group_name = var.eks_node_group_name
  max_nodes = 5
  min_nodes = 3
  desired_nodes = 3
  k8s_version = "1.37"
  cluster_name = var.eks_cluster_name
  rds_secret_arn = module.rds.rds_secret_arn
  eks_nodes_sg_id = module.sg.eks_nodes_sg_id
  eks_iam_role_arn = module.iam.eks_role_arn
  node_iam_role_arn = module.iam.node_role_arn
  pod_identity_role_arn = module.iam.pod_identity_role_arn
}

module "rds" {
  source = "./modules/rds" 
  private_subnets_ids = module.vpc.private_subnet_id
  eks_nodes_sg_id = module.sg.eks_nodes_sg_id
  vpc_id = module.vpc.vpc_id
  sg_group_id = module.sg.rds_sg_id
}

# module "ecr" {
#   source = "./modules/ecr"
#   ecr_name =  var.ecr_repo
# }
output "postgres_host" {
  value = module.rds.db_endpoint
}
output "postgres_secret_arn" {
  value = module.rds.rds_secret_arn
}