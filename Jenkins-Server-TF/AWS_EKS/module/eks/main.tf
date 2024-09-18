
data "aws_iam_policy" "AWS_EKS_POLICY" {
  name = "AmazonEKSClusterPolicy"
}
resource "aws_iam_role" "AWS_EKS_ROLE" {
  name = "aws_eks_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [data.aws_iam_policy.AWS_EKS_POLICY.arn]
}

data "aws_iam_policy" "AWS_EKS_NODE_EBS_POLICY" {
  name = "AmazonEBSCSIDriverPolicy"
}
data "aws_iam_policy" "AWS_EKS_NODE_ECR_POLICY" {
  name = "AmazonEC2ContainerRegistryReadOnly"
}
data "aws_iam_policy" "AWS_EKS_NODE_CNI_POLICY" {
  name = "AmazonEKS_CNI_Policy"
}
data "aws_iam_policy" "AWS_EKS_NODE_WORKER_POLICY" {
  name = "AmazonEKSWorkerNodePolicy"
}


resource "aws_iam_role" "AWS_EKS_NODE_ROLE" {
  name = "aws_eks_node_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [data.aws_iam_policy.AWS_EKS_NODE_CNI_POLICY.arn,data.aws_iam_policy.AWS_EKS_NODE_EBS_POLICY.arn,data.aws_iam_policy.AWS_EKS_NODE_ECR_POLICY.arn,data.aws_iam_policy.AWS_EKS_NODE_WORKER_POLICY.arn]
}


output "cluster-endpoint" {
  value = module.eks.cluster_endpoint
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${var.cluster_name}-${var.environment}"
  cluster_version = var.cluster_version
  cluster_endpoint_public_access  = false
  authentication_mode = var.authentication_mode
  create_iam_role = false
  iam_role_arn = aws_iam_role.AWS_EKS_ROLE.arn
  kms_key_aliases = ["eks01"]
  cluster_addons = {
    coredns                = {
      version=var.coreDNS_version
    }
    eks-pod-identity-agent = {
      version=var.pod_identity_agent_version
    }
    kube-proxy             = {
      version=var.kube_proxy_version
    }
    vpc-cni                = {
      version=var.vpc_cni_version
    }
  }

  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_id
  create_node_security_group = true
  create_cluster_security_group = true
  openid_connect_audiences=["sts.amazonaws.com"]
  eks_managed_node_groups = {
    example = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = var.ami_type
      instance_types = var.instance_types

      min_size     = var.managed_group_min_size
      max_size     = var.managed_group_max_size
      desired_size = var.managed_group_desired_size
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = var.cluster_admin_access
}

