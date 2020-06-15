# Passwords
resource "random_password" "user" {
  length           = 16
  special          = false
}

resource "random_password" "code-server" {
  length           = 16
  special          = false
}

# VPC
resource "digitalocean_vpc" "vpc" {
  name   = "${var.hostname}-vpc"
  region = var.region
}

# User data
data "template_file" "init" {
  template = "${file("user_data.tpl")}"
  vars = {
    HOSTNAME  = "${var.hostname}",
    USERNAME  = "${var.username}",
    USERPASS  = "${random_password.user.result}",
    CODERPASS = "${random_password.code-server.result}"
  }
}

# Droplet
resource "digitalocean_droplet" "droplet" {
  image              = "ubuntu-20-04-x64"
  name               = var.hostname
  region             = var.region
  size               = var.droplet_size
  backups            = true
  monitoring         = true
  private_networking = "true"
  ssh_keys           = [var.ssh_key_id]
  vpc_uuid           = digitalocean_vpc.vpc.id
  user_data          = data.template_file.init.rendered
}

# Volume
resource "digitalocean_volume" "disk" {
  name                    = "${var.hostname}-home"
  region                  = var.region
  size                    = var.storage_size
  initial_filesystem_type = "ext4"
  description             = "persistent storage for /home on ${var.hostname}"
}

resource "digitalocean_volume_attachment" "disk-attachment" {
  droplet_id = digitalocean_droplet.droplet.id
  volume_id  = digitalocean_volume.disk.id
}

# Loadbalancer
resource "digitalocean_loadbalancer" "lb" {
  name     = "${var.hostname}-loadbalancer"
  region   = var.region
  vpc_uuid = digitalocean_vpc.vpc.id

  forwarding_rule {
    entry_port     = 22
    entry_protocol = "tcp"

    target_port     = 22
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port     = 80
    entry_protocol = "http"

    target_port     = 8080
    target_protocol = "http"
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = ["${digitalocean_droplet.droplet.id}"]
}

# Firewall
resource "digitalocean_firewall" "firewall" {
  name = "${var.hostname}-firewall"

  droplet_ids = ["${digitalocean_droplet.droplet.id}"]

  inbound_rule {
    protocol                  = "tcp"
    port_range                = "22"
    source_load_balancer_uids = [digitalocean_loadbalancer.lb.id]
  }

  inbound_rule {
    protocol                  = "tcp"
    port_range                = "8080"
    source_load_balancer_uids = [digitalocean_loadbalancer.lb.id]
  }

  inbound_rule {
    protocol                  = "icmp"
    source_load_balancer_uids = [digitalocean_loadbalancer.lb.id]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Project
resource "digitalocean_project" "project" {
  name = var.hostname
  resources = [
    "do:droplet:${digitalocean_droplet.droplet.id}",
    "do:volume:${digitalocean_volume.disk.id}",
    "do:loadbalancer:${digitalocean_loadbalancer.lb.id}"
  ]
}