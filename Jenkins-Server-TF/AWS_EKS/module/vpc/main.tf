module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  name = "${var.nameOfVPC}-${var.environment}"
  azs = var.availability_zone
  cidr = var.vpc_cidr
  private_subnets=var.public_subnet_cidr
  public_subnets = var.private_subnet_cidr
  enable_nat_gateway = true
  private_inbound_acl_rules=[ { "cidr_block": var.vpc_cidr, "from_port": 0, "protocol": "-1", "rule_action": "allow", "rule_number": 100, "to_port": 0 }]
}


