resource "aws_eks_cluster" "eks" {
  name = var.cluster_name

  role_arn = var.eks_iam_role_arn
  version  = var.k8s_version

  bootstrap_self_managed_addons = false

  vpc_config {
    endpoint_private_access = var.enable_private_access
    endpoint_public_access  = var.enable_public_access
    subnet_ids = var.eks_subnets_ids
    security_group_ids = var.security_group_ids
  }
}

# resource "aws_iam_role" "cluster" {
#   name = "eks-cluster-example"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "sts:AssumeRole",
#           "sts:TagSession"
#         ]
#         Effect = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.cluster.name
# }

# resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
#   role       = aws_iam_role.cluster.name
# }

# resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
#   role       = aws_iam_role.cluster.name
# }

# resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
#   role       = aws_iam_role.cluster.name
# }


resource "aws_eks_node_group" "example" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_iam_role_arn
  subnet_ids      = var.eks_nodes_subnets_ids
  instance_types = var.nodes_ec2_type
  
  scaling_config {
    desired_size = var.desired_nodes
    max_size     = var.max_nodes
    min_size     = var.min_nodes
  }

  update_config {
    max_unavailable = 1
  }

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = "$Latest"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_eks_addon.vpc_cni
  ]
}

resource "aws_launch_template" "eks_nodes" {
  name_prefix = "eks-nodes-"

  vpc_security_group_ids = [
    var.eks_nodes_sg_id
  ]
}

# resource "aws_iam_role" "node" {
#   name = "eks-auto-node-example"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = ["sts:AssumeRole"]
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       },
#     ]
#   })
# }

# resource "aws_iam_role" "app_secrets" {
#   name = "eks-app-secrets-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"

#     Statement = [
#       {
#         Effect = "Allow"

#         Principal = {
#           Service = "pods.eks.amazonaws.com"
#         }

#         Action = [
#           "sts:AssumeRole",
#           "sts:TagSession"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy" "app_secrets_policy" {
#   name = "read-rds-secret"

#   role = aws_iam_role.app_secrets.id

#   policy = jsonencode({
#     Version = "2012-10-17"

#     Statement = [
#       {
#         Effect = "Allow"

#         Action = [
#           "secretsmanager:GetSecretValue",
#           "secretsmanager:DescribeSecret"
#         ]

#         Resource = var.rds_secret_arn
#       }
#     ]
#   })
# }


data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

provider "kubernetes" {
  host = aws_eks_cluster.eks.endpoint

  cluster_ca_certificate = base64decode(
    aws_eks_cluster.eks.certificate_authority[0].data
  )

  token = data.aws_eks_cluster_auth.eks.token
}


resource "kubernetes_service_account_v1" "app_sa" {
  metadata {
    name      = "app-sa"
    namespace = "default"
  }
}

resource "aws_eks_pod_identity_association" "app" {
  cluster_name = aws_eks_cluster.eks.name

  namespace = "default"

  service_account = "app-sa"

  role_arn = var.pod_identity_role_arn

  depends_on = [
    aws_eks_addon.secrets_provider,
  ]
}

# resource "aws_iam_role_policy_attachment" "example_AmazonEKS_CNI_Policy" {
#   role       = aws_iam_role.node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }

# resource "aws_iam_role_policy_attachment" "worker_node" {
#   role       = aws_iam_role.node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }

# resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
#   role       = aws_iam_role.node.name
# }

locals {
  eks_addons = ["vpc-cni", "coredns", "kube-proxy", "eks-pod-identity-agent", "aws-secrets-store-csi-driver-provider"]
}

data "aws_eks_addon_version" "addons" {
  for_each           = toset(local.eks_addons)
  addon_name         = each.key
  kubernetes_version = aws_eks_cluster.eks.version
  most_recent        = true
}
resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "vpc-cni"
  addon_version = data.aws_eks_addon_version.addons["vpc-cni"].version
}
resource "aws_eks_addon" "post_node_addons" {
  for_each      = toset(["coredns", "kube-proxy", "eks-pod-identity-agent"])
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = each.key
  addon_version = data.aws_eks_addon_version.addons[each.key].version

  depends_on = [
    aws_eks_node_group.example
  ]
}
resource "aws_eks_addon" "secrets_provider" {
  cluster_name = aws_eks_cluster.eks.name

  addon_name = "aws-secrets-store-csi-driver-provider"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  addon_version = data.aws_eks_addon_version.addons[
    "aws-secrets-store-csi-driver-provider"
  ].version

  depends_on = [
    aws_eks_node_group.example,
    aws_eks_addon.post_node_addons
  ]
}

# data "aws_iam_policy_document" "rds_secret_policy" {
#   statement {
#     effect = "Allow"

#     actions = [
#       "secretsmanager:GetSecretValue",
#       "secretsmanager:DescribeSecret"
#     ]

#     resources = [
#       var.rds_secret_arn
#     ]
#   }
# }

# resource "aws_iam_policy" "eks_read_rds_secret" {
#   name        = "EKSReadRDSSecret"
#   description = "Allow EKS application to read specific RDS secret"

#   policy = data.aws_iam_policy_document.rds_secret_policy.json
# }

# data "aws_iam_policy_document" "pod_identity_trust" {
#   statement {
#     effect = "Allow"

#     principals {
#       type = "Service"

#       identifiers = [
#         "pods.eks.amazonaws.com"
#       ]
#     }

#     actions = [
#       "sts:AssumeRole",
#       "sts:TagSession"
#     ]
#   }
# }

# resource "aws_iam_role" "eks_rds_secret_role" {
#   name = "EKS-RDS-Secret-Role"

#   assume_role_policy = data.aws_iam_policy_document.pod_identity_trust.json
# }

# resource "aws_iam_role_policy_attachment" "rds_secret_attachment" {
#   role = aws_iam_role.eks_rds_secret_role.name

#   policy_arn = aws_iam_policy.eks_read_rds_secret.arn
# }




