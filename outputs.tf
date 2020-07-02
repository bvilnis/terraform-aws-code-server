output "domain_name" {
  value       = aws_route53_record.entry.name
  description = "The domain name record"
}

output "ec2_id" {
  value       = module.ec2_instance.id
  description = "EC2 instance ID"
}

output "ec2_private_ip" {
  value       = module.ec2_instance.private_ip
  description = "EC2 instance private IP address"
}

output "ec2_public_ip" {
  value       = aws_eip.ip.public_ip
  description = "EC2 instance public IP address"
}

output "public_subnets" {
  value       = module.vpc.public_subnets
  description = "List of IDs of public subnets"
}

output "public_subnet_cidr_blocks" {
  value       = module.vpc.public_subnets_cidr_blocks
  description = "List of cidr_blocks of public subnets"
}

output "security_group_id" {
  value       = module.security_group.this_security_group_id
  description = "The ID of the security group"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "The ID of the VPC"
}