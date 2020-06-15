output "ip_address" {
  value = digitalocean_loadbalancer.lb.ip
}

output "sudo_password" {
  value = random_password.user.result
}

output "code_server_password" {
  value = random_password.code-server.result
}