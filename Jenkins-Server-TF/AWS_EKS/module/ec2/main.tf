data "aws_iam_policy" "admin_access" {
  name = "AdministratorAccess"
}
resource "aws_iam_role" "ec2_service_role" {
  name = "ec2_service_account_role"

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
  managed_policy_arns = [data.aws_iam_policy.admin_access.arn]
}
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "test_profile"
  role = aws_iam_role.ec2_service_role.name
}

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.7.0"
  name=var.name
  ami=var.ami
  associate_public_ip_address=false
  create_iam_instance_profile = false
  iam_instance_profile=aws_iam_instance_profile.ec2_instance_profile.name
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  user_data = base64encode("./user-data.sh")
}