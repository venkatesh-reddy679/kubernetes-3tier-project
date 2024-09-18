region                     = "us-west-1"
availability_zone          = ["us-west-1a", "us-west-1b"]
nameOfVPC                  = "vpc-tf-argocd"
environment                = "dev"
vpc_cidr                   = "10.20.0.0/16"
public_subnet_cidr         = ["10.20.1.0/24", "10.20.2.0/24"]
private_subnet_cidr        = ["10.20.4.0/24", "10.20.5.0/24"]
eks_cluster_name           = "eks-tf"
cluster_admin_access       = true
ami_type                   = "AL2023_x86_64_STANDARD"
instance_types             = ["m5.xlarge"]
eks_cluster_version        = "1.27"
managed_group_min_size     = 1
managed_group_max_size     = 2
managed_group_desired_size = 1
coreDNS_version            = "v1.11.1-eksbuild.8"
kube_proxy_version         = "v1.30.0-eksbuild.3"
pod_identity_agent_version = "v1.3.2-eksbuild.2"
vpc_cni_version            = "v1.18.1-eksbuild.3"
jump_server_ami            = "ami-0e86e20dae9224db8"
jump_server_instance_type  = "t2.medium"
jump_server_name           = "jump_server"
dynamoDB_table_name        = "dev-state-lock-table"
s3_bucket_name             = "dev-env-tfstate00"
path_to_store_statefile    = "terraform/dev/state"

