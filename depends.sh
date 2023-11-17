#!/bin/bash

. .env

#######################################
# Installs necessary packages, sets up Docker, and configures GPG for Docker.
# Globals:
#   VERSION_CODENAME
# Arguments:
#   None
#######################################
function install_packages() {
  echo "Removing conflicting packages..."
  local remove_packages=(docker.io docker-doc docker-compose podman-docker containerd runc)
  for package in "${remove_packages[@]}"; do
    sudo apt-get remove -y "$package"
  done

  echo "Installing required packages..."
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg uidmap inotify-tools

  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --batch --yes --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -y
  sudo apt-get install -y jq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

#######################################
# Uninstalls Docker and related packages.
# Arguments:
#   None
#######################################
function uninstall_packages() {
  echo "Attempting to uninstall packages..."
  local packages=(docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose)
  for package in "${packages[@]}"; do
    sudo apt-get purge -y "$package" || {
      echo "Error occurred during uninstallation of $package. This might have left your system in an inconsistent state."
      echo "You might want to try manually resolving package issues or consider using 'sudo apt --fix-broken install'."
    }
  done

  if [ -f /etc/apt/sources.list.d/docker.list ]; then
    echo "Removing Docker repository..."
    sudo rm /etc/apt/sources.list.d/docker.list
  fi

  sudo apt-get autoremove -y
}

#######################################
# Adjusts sysctl settings to expose specific ports.
# Arguments:
#   1 - Port number to adjust
#######################################
function adjust_sysctl_for_port() {
  local port="$1"
  local setting="net.ipv4.ip_unprivileged_port_start=$port"

  if ! grep -q "^$setting$" /etc/sysctl.conf; then
    echo "Adjusting sysctl settings to expose port $port..."
    echo "$setting" | sudo tee -a /etc/sysctl.conf > /dev/null && sudo sysctl -p
  fi
}

# Individual User Setup Methods
function setup_user_with_random_password() {
  local password
  password=$(openssl rand -base64 32)
  echo "$user_name:$password" | sudo chpasswd
  echo "Generated password for $user_name: $password"
}

#######################################
# description
# Globals:
#   USER_PASSWORD
#   user_name
# Arguments:
#  None
#######################################
function setup_user_with_env_variable() {
  local password=${USER_PASSWORD:-defaultPassword}
  echo "$user_name:$password" | sudo chpasswd
  echo "Password set for $user_name from environment variable."
}

#######################################
# description
# Globals:
#   password
#   user_name
# Arguments:
#  None
#######################################
function setup_user_with_prompt() {
  read -rsp "Enter password for $user_name: " password
  echo
  echo "$user_name:$password" | sudo chpasswd
  echo "Password set for $user_name from prompt."
}

# Unified User Setup Function
function setup_user() {
    echo "Setting up $user_name user..."

    if id "$user_name" &> /dev/null; then
        local user_choice
        echo "User $user_name already exists."
        echo "1) Reset password"
        echo "2) Skip user setup"
        read -rp "Your choice (1-2): " user_choice

        case $user_choice in
            1) choose_password_setting ;;
            2) echo "Quit." ;;
            *)
               echo "Invalid choice. Quitting."
               return
               ;;
    esac
  else
        sudo adduser --disabled-password --gecos "" "$user_name"
        choose_password_setting
  fi
}

#######################################
# description
# Arguments:
#  None
#######################################
function choose_password_setting() {
    local choice
    echo "Select method for setting user password:"
    echo "1. Generate a Random Password"
    echo "2. Use an Environment Variable .env (USER_PASSWORD)"
    echo "3. Prompt for Password"
    read -rp "Enter choice (1-5): " choice

    case $choice in
      1) setup_user_with_random_password ;;
      2) setup_user_with_env_variable ;;
      3) setup_user_with_prompt ;;
      *) echo "Invalid choice. Skipping password setup." ;;
  esac
}

#######################################
# Removes a user and their home directory, with a prompt to kill active processes.
# Globals:
#   user_name
# Arguments:
#   None
#######################################
function remove_user() {
  echo "Removing $user_name user..."
  if pgrep -u "$user_name" > /dev/null; then
    echo "There are active processes running under the $user_name user."
    read -rp "Would you like to kill all processes and continue with user removal? (y/N) " response
    if [[ $response =~ ^[Yy][Ee]?[Ss]?$ ]]; then
      sudo pkill -9 -u "$user_name"
      sleep 2  # Allow some time for processes to be terminated
    else
      echo "Skipping user removal."
      return
    fi
  fi

  sudo deluser --remove-home "$user_name"
}

#######################################
# Sets up NVM and Node.js for the specified user.
# Globals:
#   NODE_VERSION
#   nvm_install_url
#   user_name
# Arguments:
#   None
#######################################
function setup_nvm_node() {
  echo "Setting up NVM and Node.js..."

  if id "$user_name" &> /dev/null; then
    sudo mkdir -p /home/"$user_name"/.nvm
    sudo chown "$user_name:$user_name" /home/"$user_name"/.nvm

    sudo -Eu "$user_name" bash << EOF
export NVM_DIR="/home/$user_name/.nvm"
export npm_config_cache="/home/$user_name/.npm"
curl -o- $nvm_install_url | bash
source "\$NVM_DIR/nvm.sh"
nvm install $NODE_VERSION
nvm use $NODE_VERSION
nvm alias default $NODE_VERSION
npm install -g npm
EOF
  else
    echo "User $user_name does not exist. Exiting..."
    exit 1
  fi
}

#######################################
# Removes NVM and Node.js for the specified user.
# Globals:
#   user_name
# Arguments:
#   None
#######################################
function remove_nvm_node() {
  echo "Removing NVM and Node.js..."
  if id "$user_name" &> /dev/null; then
    local nvm_dir="/home/$user_name/.nvm"
    local nvm_sh="$nvm_dir/nvm.sh"

    if [ -s "$nvm_sh" ]; then
      # Load NVM and uninstall Node versions
      sudo -u "$user_name" bash -c "source $nvm_sh && nvm deactivate && nvm uninstall --lts && nvm uninstall --current"

      # Remove NVM directory
      sudo rm -rf "$nvm_dir"
      echo "NVM and Node.js removed for user $user_name."
    else
      echo "NVM is not installed for $user_name. Skipping..."
    fi
  else
    echo "User $user_name does not exist. Exiting..."
    exit 1
  fi
}

#######################################
# description
# Globals:
#   choice
# Arguments:
#  None
#######################################
function installation_menu() {
  local choice
  echo "Choose an action:"
  echo "1) Full Installation (All)"
  echo "2) Setup User Account"
  echo "3) Install Packages and Dependencies"
  echo "4) Setup NVM and Node.js"
  echo "5) Uninstall Packages and Dependencies"
  echo "6) Remove User Account"
  echo "7) Remove NVM and Node.js"
  echo "8) Full Uninstallation (All)"
  read -rp "Your choice (1-8): " choice

  case $choice in
    1)
      setup_user
      install_packages
      setup_nvm_node
      ;;
    2) setup_user ;;
    3) install_packages ;;
    4) setup_nvm_node ;;
    5) uninstall_packages ;;
    6) remove_user ;;
    7) remove_nvm_node ;;
    8)
      remove_nvm_node
      remove_user
      uninstall_packages
      ;;
    *)
      echo "Invalid choice. Exiting."
      exit 1
      ;;
  esac
}

#######################################
# Main function to control the script flow.
# Globals:
#   LANG
#   LC_ALL
#   NODE_VERSION
#   TERM
#   nvm_install_url
#   user_name
# Arguments:
#   0 - Script name
#   1 - User name (optional)
#######################################
function main() {
  export TERM=${TERM:-xterm}
  export LC_ALL=en_US.UTF-8
  export LANG=en_US.UTF-8

  set -euo pipefail

  user_name="${1:-docker-primary}"
  nvm_install_url="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh"
  NODE_VERSION="20.8.0"

  installation_menu
}

main "$@"
