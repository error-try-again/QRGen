#!/bin/bash

set -e

UNINSTALL_MODE=false

if [[ "$1" == "uninstall" ]]; then
  UNINSTALL_MODE=true
fi

install_packages() {
  local PACKAGES=(docker.io docker-doc docker-compose podman-docker containerd runc)
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
  local USER_NAME="docker-primary"
  echo "Setting up $USER_NAME user..."

  if ! id "$USER_NAME" &>/dev/null; then
    sudo adduser --disabled-password --gecos "" $USER_NAME
    echo "$USER_NAME:test" | sudo chpasswd
    # Ensure the home directory is created
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
  local USER_NAME="docker-primary"
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

  if id "docker-primary" &>/dev/null; then
    # Make sure the directory exists before setting it
    sudo mkdir -p /home/docker-primary/.nvm
    sudo chown docker-primary:docker-primary /home/docker-primary/.nvm

    sudo -Eu docker-primary bash <<'EOF'
export NVM_DIR="/home/docker-primary/.nvm"
export npm_config_cache="/home/docker-primary/.npm"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
source "$NVM_DIR/nvm.sh"
nvm install 20.8.0
nvm use 20.8.0
nvm alias default 20.8.0
npm install -g npm
EOF
  else
    echo "User docker-primary does not exist. Exiting..."
    exit 1
  fi
}

remove_nvm_node() {
  echo "Removing NVM and Node.js..."

  if id "docker-primary" &>/dev/null; then
    if [[ -f /home/docker-primary/.nvm/nvm.sh ]]; then
      sudo -Eu docker-primary bash <<'EOF'
source ~/.nvm/nvm.sh
nvm deactivate
nvm uninstall $(nvm current)
rm -rf ~/.nvm
EOF
    else
      echo "NVM is not installed for docker-primary. Skipping..."
    fi
  else
    echo "User docker-primary does not exist. Exiting..."
    exit 1
  fi
}

if $UNINSTALL_MODE; then
  remove_nvm_node
  remove_user
  uninstall_packages
else
  install_packages
  setup_user
  setup_nvm_node
fi
