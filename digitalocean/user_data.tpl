#!/bin/bash

set -ue

# Functions
mount_home_drive() {
  echo '/dev/disk/by-id/scsi-0DO_Volume_${HOSTNAME}-home /home ext4 defaults,nofail,discard 0 0' \
  | sudo tee -a /etc/fstab
  mount /home
}

update_system() {
  apt update
  apt -y dist-upgrade
  apt install -y jq systemd-container
  apt -y autoclean
  apt -y autoremove
}

add_user() {
  useradd -m -G sudo -s /bin/bash ${USERNAME}
  echo -e "${USERPASS}\n${USERPASS}" | passwd coder
  cp -r /root/.ssh /home/${USERNAME} && \
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
bind-addr: 0.0.0.0:8080
auth: password
password: ${CODERPASS}
cert: false
EOF
}

enable_code_server() {
  loginctl enable-linger ${USERNAME}
  machinectl shell --uid=${USERNAME} .host /usr/bin/systemctl --user enable --now code-server.service
}

# Exectution
mount_home_drive

update_system

add_user

install_code_server

code_server_config

enable_code_server

exit 0