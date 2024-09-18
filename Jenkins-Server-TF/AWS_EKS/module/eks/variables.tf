variable "vpc_id" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "cluster_version" {
  type = string
}
variable "environment" {
  type = string
}
variable "authentication_mode" {
  type = string
  default = "API_AND_CONFIG_MAP"
}
variable "subnet_id" {
  type = list(string)
}
variable "coreDNS_version" {
  type = string
}
variable "pod_identity_agent_version" {
  type=string
}
variable "kube_proxy_version" {
  type=string
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
  type= number
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
