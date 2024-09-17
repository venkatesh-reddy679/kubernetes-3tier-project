data "aws_iam_policy" "admin_access" {
  name = "AdministratorAccess"
}
data "aws_iam_policy" "ssm"{
  name =  "AmazonSSMManagedInstanceCore"
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
  managed_policy_arns = [data.aws_iam_policy.admin_access.arn, data.aws_iam_policy.ssm.arn]
}
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "test_profile"
  role = aws_iam_role.ec2_service_role.name
}
resource "aws_security_group" "sg-jump-server" {
   vpc_id = var.vpc_ID
   egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }
   tags={
     "Name"="jump-server-sg"
   }
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
  vpc_security_group_ids = [aws_security_group.sg-jump-server]
  user_data = filebase64("./user-data.sh")
}
