variable "region" {
  type = string
}
variable "nameOfVPC" {
  type = string
}
variable "environment" {
  type        = string
  description = "provide the name of the environemt you are deploying to"
}
variable "vpc_cidr" {
  type        = string
  description = "provide the CIDR for the vpc. for example, 10.10.0.0/16"
}
variable "availability_zone" {
  type        = list(string)
  description = "provide the az's to create subnets"
}
variable "public_subnet_cidr" {
  type        = list(string)
  description = "provide the list of cidr to be used for public subnets. for example, ['10.10.1.0/24','10.10.2.0/24','10.10.3.0/24']"

}
variable "private_subnet_cidr" {
  type        = list(string)
  description = "provide the list of cidr to be used for private subnets. for example, ['10.10.4.0/24','10.10.5.0/24','10.10.6.0/24']"
}
variable "eks_cluster_name" {
  type = string
}
variable "eks_cluster_version" {
  type = string
}
variable "coreDNS_version" {
  type = string
}
variable "pod_identity_agent_version" {
  type = string
}
variable "kube_proxy_version" {
  type = string
}
variable "vpc_cni_version" {
  type = string
}
variable "ami_type" {
  type = string
}
variable "instance_types" {
  type = list(string)
}
variable "managed_group_min_size" {
  type = number
}
variable "managed_group_max_size" {
  type = number
}
variable "managed_group_desired_size" {
  type = number
}
variable "cluster_admin_access" {
  type = bool
}

variable "jump_server_ami" {
  type = string
}
variable "jump_server_instance_type" {
  type = string
}
variable "jump_server_name" {
  type = string
}
variable "s3_bucket_name" {
  type = string
}
variable "path_to_store_statefile" {
  type = string
}
variable "dynamoDB_table_name" {
  type = string
}