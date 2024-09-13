variable "ami" {
  type=string
}
variable "instance_type" {
  type = string
}
variable "name" {
  type=string
}
variable "subnet_id" {
  type=string
}
variable "vpc_security_group_ids" {
  type=list(string)
}