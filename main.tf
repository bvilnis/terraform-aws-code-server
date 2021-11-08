provider "aws" {
  region = var.region
}

# Locals
locals {
  tags = {
    Name      = "${var.github_username}-code-server"
    Terraform = true
  }
}

# Passwords
resource "random_password" "user" {
  length  = 16
  special = false
}

# Cookie string
resource "random_password" "cookie" {
  length  = 16
  special = false
}

# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  cidr           = "10.0.0.0/16"
  azs            = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  tags           = local.tags
}

# Security group
module "security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name                = var.hostname
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "ssh-tcp", "all-icmp"]
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
  template = file("${path.module}/user_data.tpl")
  vars = {
    HOSTNAME             = "${var.hostname}",
    USERNAME             = "${var.username}",
    USERPASS             = "${random_password.user.result}",
    GITHUB_USER          = "${var.github_username}",
    DOMAIN               = "${var.domain_name}",
    OAUTH2_CLIENT_ID     = "${var.oauth2_client_id}",
    OAUTH2_CLIENT_SECRET = "${var.oauth2_client_secret}",
    OAUTH2_PROVIDER      = "${var.oauth2_provider}",
    EMAIL                = "${var.email_address}",
    COOKIE               = base64encode("${random_password.cookie.result}")
  }
}

module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = var.hostname
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_size
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
  user_data                   = data.template_file.user_data.rendered

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    }
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

resource "aws_eip" "ip" {
  instance = module.ec2_instance.id[0]
  vpc      = true
}

# Domain
resource "aws_route53_record" "entry" {
  zone_id = var.route53_zone_id
  name    = var.domain_name
  type    = "A"
  ttl     = "3600"
  records = [aws_eip.ip.public_ip]
}
