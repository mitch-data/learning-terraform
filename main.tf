data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}


data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  # replaced by module defined in line 43
  # vpc_security_group_ids = [aws_security_group.blog.id]
  vpc_security_group_ids = [module.blog_sg.security_group_id]

  tags = {
    Name = "Learning Terraform"
  }
}

# Define module
module "blog_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.3.0"
  name    =  "blog"

  vpc_id      = data.aws_vpc.default.id

  # https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/rules.tf
  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  # syntax to define values https://registry.terraform.io/modules/terraform-aws-modules/security-group/aws/latest?tab=inputs
  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

# NTS: line 52 - 89 replaced by the module defined in line 43 - 50
# Define Security Group for AWS instance
# resource "aws_security_group" "blog" {
#  name        = "blog"
#  description = "Allow http and https in. Allow everything out"
#
#  vpc_id      = data.aws_vpc.default.id
# }

#resource "aws_security_group_rule" "blog_http_in" {
#  type        = "ingress"
#  from_port   = 80
#  to_port     = 80
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"] # define networks
#
#  security_group_id = aws_security_group.blog.id
#}

#resource "aws_security_group_rule" "blog_https_in" {
#  type        = "ingress"
#  from_port   = 443
#  to_port     = 433
#  protocol    = "tcp"
#  cidr_blocks = ["0.0.0.0/0"] # define networks
#
#  security_group_id = aws_security_group.blog.id
#}

#resource "aws_security_group_rule" "blog_everything_out" {
#  type        = "egress"
#  from_port   = 0  # allow any port
#  to_port     = 0 
#  protocol    = "-1" # allow all protocol
#  cidr_blocks = ["0.0.0.0/0"] # define networks
#
#  security_group_id = aws_security_group.blog.id
#}