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

add_user() {
  useradd -m -G sudo -s /bin/bash ${USERNAME}
  echo -e "${USERPASS}\n${USERPASS}" | passwd ${USERNAME}
  mkdir /home/${USERNAME}/.ssh && \
  curl https://github.com/${GITHUB_USER}.keys >> /home/${USERNAME}/.ssh/authorized_keys && \
  chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.ssh
}

update_system() {
  echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" \
  | sudo tee -a /etc/apt/sources.list.d/caddy-fury.list
  apt update
  apt -y dist-upgrade
  apt install -y jq systemd-container caddy
  apt -y autoclean
  apt -y autoremove
}

install_code_server() {
  CODE_SERVER_RELEASE=$(curl -s https://api.github.com/repos/cdr/code-server/releases/latest \
  | jq -r ".assets[] | select(.name | test(\"amd64.deb\")) | .browser_download_url")
  DEB=$(echo "$CODE_SERVER_RELEASE" | awk -F'/' '{print $9}')

  wget "$CODE_SERVER_RELEASE"
  yes | dpkg -i "$DEB"
  rm "$DEB"
}

code_server_config() {
  mkdir -p /home/${USERNAME}/.config/code-server && \
  chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/.config
  cat <<EOF > "/home/${USERNAME}/.config/code-server/config.yaml"
bind-addr: 127.0.0.1:8080
auth: none
password:
cert: false
EOF
}

enable_code_server() {
  loginctl enable-linger ${USERNAME}
  machinectl shell --uid=${USERNAME} .host /usr/bin/systemctl --user enable --now code-server.service
}

install_oauth2_proxy() {
  OAUTH2_PROXY_RELEASE=$(curl -s https://api.github.com/repos/oauth2-proxy/oauth2-proxy/releases/latest \
  | jq -r ".assets[] | select(.name | test(\"linux-amd64.go\")) | .browser_download_url")
  TARBALL=$(echo "$OAUTH2_PROXY_RELEASE" | awk -F'/' '{print $9}')

  wget "$OAUTH2_PROXY_RELEASE"
  tar -xzf "$TARBALL" -C /usr/local/bin --strip-components=1
  rm "$TARBALL"
}

oauth2_proxy_config() {
  mkdir /etc/oauth2_proxy

  if [ -z ${EMAIL} ]; then
    EMAIL_CONFIG='email_domains = ["*"]'
  else
    EMAIL_CONFIG='authenticated_emails_file = "/etc/oauth2_proxy/email_list.cfg"'
    echo ${EMAIL} > /etc/oauth2_proxy/email_list.cfg
  fi

  cat <<EOF > "/etc/oauth2_proxy/oauth2_proxy.cfg"
## OAuth provider
provider = "${OAUTH_PROVIDER}"

## <addr>:<port> to listen on for HTTP/HTTPS clients
 http_address  = "127.0.0.1:4180"
 https_address = ":443"

## Are we running behind a reverse proxy? Will not accept headers like X-Real-Ip unless this is set.
 reverse_proxy = true

## the http url(s) of the upstream endpoint. If multiple, routing is based on path
 upstreams = [
     "http://127.0.0.1:8080/"
 ]

## Logging configuration
logging_filename        = "/var/log/oauth2_proxy.log"
logging_max_size        = 100
logging_max_age         = 7
logging_local_time      = true
logging_compress        = false
standard_logging        = true
standard_logging_format = "[{{.Timestamp}}] [{{.File}}] {{.Message}}"
request_logging         = true
request_logging_format  = "{{.Client}} - {{.Username}} [{{.Timestamp}}] {{.Host}} {{.RequestMethod}} {{.Upstream}} {{.RequestURI}} {{.Protocol}} {{.UserAgent}} {{.StatusCode}} {{.ResponseSize}} {{.RequestDuration}}"
auth_logging            = true
auth_logging_format     = "{{.Client}} - {{.Username}} [{{.Timestamp}}] [{{.Status}}] {{.Message}}"

## pass HTTP Basic Auth, X-Forwarded-User and X-Forwarded-Email information to upstream
 pass_basic_auth   = true
 pass_user_headers = true
## pass the request Host Header to upstream
 pass_host_header = true

## Authenticated Email Addresses
 $EMAIL_CONFIG

## The OAuth Client ID, Secret
 client_id     = "${CLIENT_ID}"
 client_secret = "${CLIENT_SECRET}"

## Cookie Settings
 cookie_name     = "_oauth2_proxy"
 cookie_secret   = "${COOKIE}"
 cookie_expire   = "168h"
 cookie_refresh  = "1h"
 cookie_secure   = true
 cookie_httponly = true

## Skip Provider Screen
skip_provider_button = true
EOF
}

enable_oauth2_proxy() {
cat <<EOF > "/etc/systemd/system/oauth2_proxy.service"
[Unit]
Description=Oauth2 Proxy
After=network.target
[Service]
ExecStart=oauth2_proxy --config=/etc/oauth2_proxy/oauth2_proxy.cfg
Restart=on-failure
RestartSec=5
User=root
[Install]
WantedBy=multi-user.target
EOF

chmod 0755 /etc/systemd/system/oauth2_proxy.service
systemctl enable --now oauth2_proxy.service
}

caddy_config() {
  cat <<EOF > "/etc/caddy/Caddyfile"
${DOMAIN}

reverse_proxy 127.0.0.1:4180
EOF
  systemctl restart caddy.service
}

main () {
  update_hostname

  mount_home_drive

  add_user

  update_system

  install_code_server

  code_server_config

  enable_code_server

  install_oauth2_proxy

  oauth2_proxy_config

  enable_oauth2_proxy

  caddy_config
}

# Exectution
main

exit 0
