# create role for the cluster
resource "aws_iam_role" "cluster" {
  name = var.eks_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

# attach policies to the cluster role
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicies" {
  for_each =  toset(var.eks_cluster_policies_arns)
  policy_arn = each.value
  role       = aws_iam_role.cluster.name
}
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

# create role for the nodes
resource "aws_iam_role" "node" {
  name = var.eks_node_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

# attach polices to the nodes role 
# locals {
#   node_policies = [
#     "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
#     "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
#     "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   ]
# }

resource "aws_iam_role_policy_attachment" "node_policies" {
  for_each = toset(var.node_policies)
  role       = aws_iam_role.node.name
  policy_arn = each.value
}

# create role to allow EKS Pod Identity Service to assume role
resource "aws_iam_role" "pod_identity_role" {
  name = var.pod_identity_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "pods.eks.amazonaws.com"
        }

        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

# attach policy to pod role
resource "aws_iam_role_policy" "pod_policy" {
  name = var.pod_policy_name

  role = aws_iam_role.pod_identity_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = var.pod_policy_actions_to_allow
        
        # [
        #   "secretsmanager:GetSecretValue",
        #   "secretsmanager:DescribeSecret"
        # ]

        Resource = var.resource_policy_allow_on_arn
      }
    ]
  })
}


