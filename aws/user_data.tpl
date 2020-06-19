#!/bin/bash

set -ue

# Functions
update_hostname() {
  hostnamectl set-hostname ${HOSTNAME}
}

mount_home_drive() {
  mkfs -t ext4 /dev/nvme1n1
  echo '/dev/nvme1n1 /home ext4 defaults,nofail,discard 0 0' \
  | sudo tee -a /etc/fstab
  mount /home
}

update_system() {
  apt update
  apt -y dist-upgrade
  apt install -y jq systemd-container nginx
  apt -y autoclean
  apt -y autoremove
}

add_user() {
  useradd -m -G sudo -s /bin/bash ${USERNAME}
  echo -e "${USERPASS}\n${USERPASS}" | passwd ${USERNAME}
  mkdir /home/${USERNAME}/.ssh && \
  curl https://github.com/${GITHUB_USER}.keys >> /home/${USERNAME}/.ssh/authorized_keys && \
  chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh
}

install_code_server() {
  RELEASE=$(curl -s https://api.github.com/repos/cdr/code-server/releases/latest \
  | jq -r ".assets[] | select(.name | test(\"amd64.deb\")) | .browser_download_url")
  DEB=$(echo "$RELEASE" | awk -F'/' '{print $9}')

  wget "$RELEASE"
  yes | dpkg -i "$DEB"
  rm "$DEB"
}

code_server_config() {
  mkdir -p /home/${USERNAME}/.config/code-server && \
  chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config
  cat <<EOF > "/home/${USERNAME}/.config/code-server/config.yaml"
bind-addr: 127.0.0.1:8080
auth: password
password: ${CODERPASS}
cert: false
EOF
}

enable_code_server() {
  loginctl enable-linger ${USERNAME}
  machinectl shell --uid=${USERNAME} .host /usr/bin/systemctl --user enable --now code-server.service
}

nginx_config() {
  unlink /etc/nginx/sites-enabled/default
  cat <<EOF > "/etc/nginx/sites-available/reverse-proxy.conf"
server {
  listen 80;
  listen [::]:80;
    location / {
       proxy_pass http://localhost:8080/;
       proxy_set_header Upgrade \$http_upgrade;
       proxy_set_header Connection upgrade;
    }
}
EOF
  ln -s /etc/nginx/sites-available/reverse-proxy.conf /etc/nginx/sites-enabled/reverse-proxy.conf
  systemctl restart nginx.service
}

main () {
  update_hostname

  mount_home_drive

  update_system

  add_user

  install_code_server

  code_server_config

  enable_code_server

  nginx_config
}

# Exectution
main

exit 0