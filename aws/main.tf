provider "aws" {
  region = var.region
}

# Locals
locals {
  tags = {
    Name      = var.hostname
    Terraform = true
  }
}

# Passwords
resource "random_password" "user" {
  length  = 16
  special = false
}

resource "random_password" "code-server" {
  length  = 16
  special = false
}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  cidr                 = "10.0.0.0/16"
  azs                  = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  enable_dns_hostnames = true
  tags                 = local.tags
}

# Security group
module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name                = var.hostname
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]
  tags                = local.tags
}

# EC2
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "user_data" {
  template = file("user_data.tpl")
  vars = {
    HOSTNAME    = "${var.hostname}",
    USERNAME    = "${var.username}",
    USERPASS    = "${random_password.user.result}",
    CODERPASS   = "${random_password.code-server.result}",
    GITHUB_USER = "${var.github_username}"
  }
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = var.hostname
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_size
  subnet_ids                  = module.vpc.public_subnets
  vpc_security_group_ids      = [module.security_group.this_security_group_id]
  associate_public_ip_address = true
  user_data                   = data.template_file.user_data.rendered

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    },
  ]

  ebs_block_device = [
    {
      device_name           = "/dev/sdf"
      volume_type           = "gp2"
      volume_size           = var.storage_size
      delete_on_termination = false
    }
  ]

  tags = local.tags
}
