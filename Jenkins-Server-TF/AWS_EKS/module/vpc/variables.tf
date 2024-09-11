variable "nameOfVPC"{
  type=string
}
variable "environment"{
  type = string
  description = "provide the name of the environemt you are deploying to"
}
variable "vpc_cidr" {
  type=string
  description = "provide the CIDR for the vpc. for example, 10.10.0.0/16"
  validation {
    condition = endswith(var.vpc_cidr,"/16")
    error_message = "provided cidr must contain /16 cidr"
  }
}
variable "availability_zone" {
  type=list(string)
  description = "provide the az's to create subnets"
  validation {
    condition = length(var.availability_zone) >= 3
    error_message = "please provide minimum of 3 availability zones for HA"
  }
}

variable "public_subnet_cidr" {
  type = list(string)
  description = "provide the list of cidr to be used for public subnets. for example, ['10.10.1.0/24','10.10.2.0/24','10.10.3.0/24']"
  validation {
    condition = length(var.public_subnet_cidr) >= 3
    error_message = "required 3 subnets for provides AZ's"
  }
}
variable "private_subnet_cidr" {
  type = list(string)
  description = "provide the list of cidr to be used for private subnets. for example, ['10.10.4.0/24','10.10.5.0/24','10.10.6.0/24']"
  validation {
    condition = length(var.private_subnet_cidr) >=3
    error_message = "required 3 subnets for provides AZ's"
  }
}
