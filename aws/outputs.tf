output "domain" {
  value = module.ec2_instance.public_dns
}

output "sudo_password" {
  value = random_password.user.result
}

output "code_server_password" {
  value = random_password.code-server.result
}