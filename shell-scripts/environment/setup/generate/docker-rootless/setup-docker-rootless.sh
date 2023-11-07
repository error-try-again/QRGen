#!/bin/bash

# Configures Docker to operate in rootless mode, updating user's bashrc as required.
setup_docker_rootless() {
  echo "Setting up Docker in rootless mode..."

  # Validate Docker installation.
  if ! command -v docker &>/dev/null; then
    echo "Docker is not installed. Please install Docker to continue."
    exit 1
  fi

  # Ensure rootless setup tool is available before attempting setup.
  if ! command -v dockerd-rootless-setuptool.sh >/dev/null 2>&1; then
    echo "dockerd-rootless-setuptool.sh not found. Exiting."
    return 1
  else
    dockerd-rootless-setuptool.sh install
  fi

  # Ensure Docker environment variables are set.
  test_docker_env

  # Append environment settings to the user's bashrc.
  add_to_bashrc() {
    local line="$1"
    if ! grep -q "^${line}$" ~/.bashrc; then
      echo "$line" >>~/.bashrc
    fi
  }

  add_to_bashrc "export PATH=/usr/bin:$PATH"
  add_to_bashrc "export XDG_RUNTIME_DIR=/run/user/$(id -u)"
  add_to_bashrc "DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock"

  # Manage Docker's systemd services.
  systemctl --user status docker.service
  systemctl --user start docker.service
  systemctl --user enable docker.service
}
