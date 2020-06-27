output "sudo_password" {
  value = "The sudo password for the user '${var.username}' is '${random_password.user.result}'. Make sure you save this password now in order to run sudo commands or change the password."
}
