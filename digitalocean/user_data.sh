#!/bin/bash

set -e

## Functions ##
mount_home_drive() {
  echo '/dev/disk/by-id/scsi-0DO_Volume_linux-cloudstation-home /home ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab
  mount /home
}

update_system() {
  apt update
  apt full-upgrade
  apt install -y jq
}

download_code_server() {
  RELEASE=$(curl -s https://api.github.com/repos/cdr/code-server/releases/latest | jq -r ".assets[] | select(.name | test(\"linux\")) | .browser_download_url")
  TARBALL=$(echo "$RELEASE" | awk -F'/' '{print $9}')

  wget "$RELEASE"
  mkdir code-server-tarball
  tar -xzf "$TARBALL" -C code-server-tarball --strip-components=1
  cp code-server-tarball/code-server /usr/local/bin
  rm -r "$TARBALL" code-server-tarball
}

add_user() {
  useradd -m -G sudo -s /bin/bash coder
  echo "coder:coder" | sudo chpasswd
  cp -r /root/.ssh /home/coder
  chown -R coder:coder /home/coder/.ssh
  chage -d 0 coder
}

create_config_dir() {
  if [ ! -d /home/coder/code-server ]; then
    mkdir /home/coder/code-server
    chown -R coder:coder /home/coder/code-server
  fi
}

code_server_systemd() {
cat <<EOF > "/etc/systemd/system/code-server.service"
[Unit]
Description=Visual Studio Code on the server
After=network.target

[Service]
ExecStart=/usr/local/bin/code-server --user-data-dir /home/coder/code-server
Restart=on-failure
RestartSec=5
User=coder

[Install]
WantedBy=multi-user.target
EOF

chmod 0755 /etc/systemd/system/code-server.service
systemctl enable code-server.service
}

code_server_scripts() {
cat <<EOF > "/usr/local/bin/code-server-init"
#!/bin/bash

set -e

## Functions ##
set_password() {
  while true; do
    read -s -p "Set password for Code Server: " PASSWORD
    echo
    read -s -p "Enter password again: " PASSWORD2
    echo
    [ "\$PASSWORD" = "\$PASSWORD2" ] && break
    echo "Passwords did not match. Please try again."
  done

  sed -i "8 i Environment="PASSWORD=\${PASSWORD}"" "/etc/systemd/system/code-server.service"

  systemctl daemon-reload
  systemctl restart code-server.service
}

change_password() {
  sed -i "8d" "/etc/systemd/system/code-server.service"
  set_password
}

check_for_password() {
  if ! grep -q PASSWORD "/etc/systemd/system/code-server.service"; then
    set_password
  else
    read -p "Password is already set. Would you like to change it? (y/n): " ANSWER
      if [[ "\$ANSWER" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        change_password
        echo "Your password has successfully been changed."
      else
        echo "Your password has not been changed."
      fi
  fi
}

## Execution ##
check_for_password

exit 0
EOF

cat <<EOF > "/usr/local/bin/code-server-upgrade"
#!/bin/bash

set -e

## Functions ##
upgrade_code_server() {
  RELEASE=$(curl -s https://api.github.com/repos/cdr/code-server/releases/latest | jq -r ".assets[] | select(.name | test(\"linux\")) | .browser_download_url")
  TARBALL=$(echo "$RELEASE" | awk -F'/' '{print $9}')

  wget "\$RELEASE"
  mkdir code-server-upgrade
  tar -xzf "\$TARBALL" -C code-server-upgrade --strip-components=1
  rm /usr/local/bin/code-server
  cp code-server-upgrade/code-server /usr/local/bin
  rm -r "\$TARBALL" code-server-upgrade

  systemctl restart code-server.service

  echo "Code Server has successfully updated!"
}

## Execution ##
upgrade_code_server

exit 0
EOF

chmod 0755 /usr/local/bin/code-server-init
chmod 0755 /usr/local/bin/code-server-upgrade
}

## Exectution ##
mount_home_drive

update_system

download_code_server

add_user

create_config_dir

code_server_systemd

code_server_scripts

exit 0