#!/bin/bash

set -euo pipefail

# Configuration Variables
USER_NAME="${1:-docker-primary}"
NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh"
NODE_VERSION="20.8.0"

# Ensure correct number of arguments
if [[ $# -gt 2 ]]; then
  echo "Usage: $0 [username] [uninstall]"
  exit 1
fi

UNINSTALL_MODE=false
if [[ "${2:-}" == "uninstall" ]]; then
  UNINSTALL_MODE=true
fi

# ---- Package Install/Uninstall ---- #

install_packages() {
  echo "Removing conflicting packages..."
  local REMOVE_PACKAGES=(docker.io docker-doc docker-compose podman-docker containerd runc)
  local package
  for package in "${REMOVE_PACKAGES[@]}"; do
    sudo apt-get remove -y "$package"
  done

  echo "Installing required packages..."

  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg uidmap

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt-get update -y
  sudo apt-get install -y jq docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin
}

uninstall_packages() {
  echo "Attempting to uninstall packages..."

  local PACKAGES=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose)
  local package
  for package in "${PACKAGES[@]}"; do
    sudo apt-get purge -y "$package" || {
      echo "Error occurred during uninstallation of $package. This might have left your system in an inconsistent state."
      echo "You might want to try manually resolving package issues or consider using 'sudo apt --fix-broken install'."
    }
  done

  sudo rm /etc/apt/sources.list.d/docker.list
  sudo apt-get autoremove -y
}

# ---- Helper Functions ---- #

is_port_exposable() {
  nc -zv 127.0.0.1 "$1" &>/dev/null
}

setup_authbind_for_port() {
  local port="$1"
  sudo touch "/etc/authbind/byport/$port"
  sudo chown "$USER_NAME" "/etc/authbind/byport/$port"
  sudo chmod 755 "/etc/authbind/byport/$port"
}

# ---- User Functions ---- #

setup_user() {
  echo "Setting up $USER_NAME user..."
  if ! id "$USER_NAME" &>/dev/null; then
    sudo adduser --disabled-password --gecos "" "$USER_NAME"
    echo "$USER_NAME:test" | sudo chpasswd
  fi

  # Authbind ports 80 and 443 for HTTP01 Challenge (Certbot)
  local port
  for port in 80 443; do
    if ! is_port_exposable "$port"; then
      setup_authbind_for_port "$port"
    fi
  done
}

remove_user() {
  echo "Removing $USER_NAME user..."
  local response

  if pgrep -u "$USER_NAME" >/dev/null; then
    echo "There are active processes running under the $USER_NAME user."
    read -r "Would you like to kill all processes and continue with user removal? (y/N) " response
    if [[ "$response" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
      pkill -u "$USER_NAME"
    else
      echo "Skipping user removal."
      return
    fi
  fi

  sudo deluser --remove-home "$USER_NAME"
}

# ---- Node ---- #

setup_nvm_node() {
  echo "Setting up NVM and Node.js..."

  if id "$USER_NAME" &>/dev/null; then
    sudo mkdir -p /home/"$USER_NAME"/.nvm
    sudo chown "$USER_NAME":"$USER_NAME" /home/"$USER_NAME"/.nvm

    sudo -Eu "$USER_NAME" bash <<EOF
export NVM_DIR="/home/$USER_NAME/.nvm"
export npm_config_cache="/home/$USER_NAME/.npm"
curl -o- $NVM_INSTALL_URL | bash
source "\$NVM_DIR/nvm.sh"
nvm install $NODE_VERSION
nvm use $NODE_VERSION
nvm alias default $NODE_VERSION
npm install -g npm
EOF
  else
    echo "User $USER_NAME does not exist. Exiting..."
    exit 1
  fi
}

remove_nvm_node() {
  echo "Removing NVM and Node.js..."
  if id "$USER_NAME" &>/dev/null; then
    if [[ -f /home/$USER_NAME/.nvm/nvm.sh ]]; then
      sudo -Eu "$USER_NAME" bash <<'EOF'
source ~/.nvm/nvm.sh
nvm deactivate
nvm uninstall $(nvm current)
rm -rf ~/.nvm
EOF
    else
      echo "NVM is not installed for $USER_NAME. Skipping..."
    fi
  else
    echo "User $USER_NAME does not exist. Exiting..."
    exit 1
  fi
}

# ---- Main Function/Entry ---- #

if $UNINSTALL_MODE; then
  remove_nvm_node
  remove_user
  uninstall_packages
else
  install_packages
  setup_user
  setup_nvm_node
fi
