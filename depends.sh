#!/bin/bash

set -euo pipefail

# Configuration Variables
USER_NAME="docker-primary"
NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh"
NODE_VERSION="20.8.0"

# Ensure correct number of arguments
if [[ $# -gt 1 ]]; then
    echo "Usage: $0 [uninstall]"
    exit 1
fi

UNINSTALL_MODE=false
if [[ "${1:-}" == "uninstall" ]]; then
    UNINSTALL_MODE=true
fi


install_packages() {
  local PACKAGES=(docker.io docker-doc docker-compose podman-docker containerd runc systemd-container)
  for package in "${PACKAGES[@]}"; do
    sudo apt-get remove -y $package
  done

  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

  sudo apt-get update -y
  sudo apt-get install -y jq ca-certificates curl git gnupg docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin uidmap
}

setup_user() {
  echo "Setting up $USER_NAME user..."

  if ! id "$USER_NAME" &>/dev/null; then
    sudo adduser --disabled-password --gecos "" $USER_NAME
    echo "$USER_NAME:test" | sudo chpasswd
    if [[ ! -d "/home/$USER_NAME" ]]; then
      sudo mkdir "/home/$USER_NAME"
      sudo chown $USER_NAME:$USER_NAME "/home/$USER_NAME"
    fi
  fi
}

uninstall_packages() {
  echo "Attempting to uninstall packages..."

  local PACKAGES=(jq ca-certificates curl git gnupg docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin uidmap)
  for package in "${PACKAGES[@]}"; do
    if ! sudo apt-get purge -y $package; then
      echo "Error occurred during uninstallation of $package. This might have left your system in an inconsistent state."
      echo "You might want to try manually resolving package issues or consider using 'sudo apt --fix-broken install'."
      return 1
    fi
  done

  sudo rm /etc/apt/sources.list.d/docker.list
  sudo apt-get autoremove -y
}

remove_user() {
  echo "Removing $USER_NAME user..."

  if pgrep -u $USER_NAME >/dev/null; then
    echo "There are active processes running under the $USER_NAME user."
    read -rp "Would you like to kill all processes and continue with user removal? (y/N) " response
    if [[ "$response" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
      pkill -u $USER_NAME
    else
      echo "Skipping user removal."
      return
    fi
  fi

  sudo deluser --remove-home $USER_NAME
}

setup_nvm_node() {
  echo "Setting up NVM and Node.js..."

  if id "$USER_NAME" &>/dev/null; then
    sudo mkdir -p /home/$USER_NAME/.nvm
    sudo chown $USER_NAME:$USER_NAME /home/$USER_NAME/.nvm

    sudo -Eu $USER_NAME bash <<EOF
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
      sudo -Eu $USER_NAME bash <<'EOF'
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

# Main Execution
if $UNINSTALL_MODE; then
    remove_nvm_node
    remove_user
    uninstall_packages
else
    install_packages
    setup_user
    setup_nvm_node
fi
