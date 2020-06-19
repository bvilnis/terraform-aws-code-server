output "ip_address" {
  value = digitalocean_droplet.droplet.ipv4_address
}

output "sudo_password" {
  value = random_password.user.result
}

output "code_server_password" {
  value = random_password.code-server.result
}