## Droplet ##
resource "digitalocean_droplet" "linux-cloudstation" {
  image  = "ubuntu-18-04-x64"
  name   = var.name
  region = var.region
  size   = var.droplet_size
  backups = true
  monitoring = true
  private_networking = "true"
  user_data = file("user_data.sh")
  ssh_keys = [var.ssh_key_id]
}

## Volume ##
resource "digitalocean_volume" "linux-cloudstation" {
  name                    = "${var.name}-home"
  region                  = var.region
  size                    = var.storage_size
  initial_filesystem_type = "ext4"
  description             = "persistent storage for /home on linux-cloudstation"
}

resource "digitalocean_volume_attachment" "linux-cloudstation" {
  droplet_id = digitalocean_droplet.linux-cloudstation.id
  volume_id  = digitalocean_volume.linux-cloudstation.id
}

## Loadbalancer ##
resource "digitalocean_loadbalancer" "linux-cloudstation" {
  name = "${var.name}-loadbalancer"
  region = var.region

  forwarding_rule {
    entry_port = 22
    entry_protocol = "tcp"

    target_port = 22
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 8080
    target_protocol = "http"
  }

  healthcheck {
    port     = 22
    protocol = "tcp"
  }

  droplet_ids = ["${digitalocean_droplet.linux-cloudstation.id}"]
}

## Firewall ##
resource "digitalocean_firewall" "linux-cloudstation" {
  name = "${var.name}-firewall"

  droplet_ids = ["${digitalocean_droplet.linux-cloudstation.id}"]

  inbound_rule {
      protocol                  = "tcp"
      port_range                = "22"
      source_load_balancer_uids = [digitalocean_loadbalancer.linux-cloudstation.id]
  }

  inbound_rule {
      protocol                  = "tcp"
      port_range                = "8080"
      source_load_balancer_uids = [digitalocean_loadbalancer.linux-cloudstation.id]
  }

  inbound_rule {
      protocol                  = "icmp"
      source_load_balancer_uids = [digitalocean_loadbalancer.linux-cloudstation.id]
  }

  outbound_rule {
      protocol                = "tcp"
      port_range              = "1-65535"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
      protocol                = "udp"
      port_range              = "1-65535"
      destination_addresses   = ["0.0.0.0/0", "::/0"]
  }
}

## Project ##
resource "digitalocean_project" "linux-cloudstation" {
  name        = var.name
  resources   = [
    "do:droplet:${digitalocean_droplet.linux-cloudstation.id}",
    "do:volume:${digitalocean_volume.linux-cloudstation.id}",
    "do:loadbalancer:${digitalocean_loadbalancer.linux-cloudstation.id}",
    ]
}