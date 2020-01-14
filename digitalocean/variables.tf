variable "name" {
  type = string
  default = "linux-cloudstation"
}

variable "region" {
  type = string
}

variable "droplet_size" {
  type = string
}

variable "storage_size" {
  type = number
}

variable "ssh_key_id" {
  type = number
}
