terraform {
  backend "s3" {}
}
provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../module/vpc"

  nameOfVPC           = var.nameOfVPC
  availability_zone   = var.availability_zone
  environment         = var.environment
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  vpc_cidr            = var.vpc_cidr
}
module "eks" {
  source                     = "../module/eks"
  cluster_name               = var.eks_cluster_name
  cluster_version            = var.eks_cluster_version
  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  subnet_id                  = module.vpc.vpc_private_subnets
  cluster_admin_access       = true
  ami_type                   = var.ami_type
  coreDNS_version            = var.coreDNS_version
  kube_proxy_version         = var.kube_proxy_version
  vpc_cni_version            = var.vpc_cni_version
  managed_group_desired_size = var.managed_group_desired_size
  managed_group_min_size     = var.managed_group_min_size
  managed_group_max_size     = var.managed_group_max_size
  instance_types             = var.instance_types
  pod_identity_agent_version = var.pod_identity_agent_version
}

module "jump_server" {
  source                 = "../module/ec2"
  instance_type          = var.jump_server_instance_type
  ami                    = var.jump_server_ami
  name                   = var.jump_server_name
  subnet_id              = module.vpc.vpc_private_subnets[0]
  vpc_id                     = module.vpc.vpc_id
}



