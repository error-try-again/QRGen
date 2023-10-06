#!/bin/bash

# Exit on any error
set -e

# --------- Dependency Setup Functions ---------

# Install required packages for rootless-docker, request handling
install_packages() {
  local PACKAGES
  local package
  PACKAGES=(docker.io docker-doc docker-compose podman-docker containerd runc)

  for package in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $package; done


  # Add Docker's official GPG key:
  sudo apt-get update -y &&
  sudo apt-get install ca-certificates curl gnupg &&
  sudo install -m 0755 -d /etc/apt/keyrings &&
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg

  # Add the repository to Apt sources:
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl git gnupg docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin uidmap
}

# Create defacto docker account and user process persistence across logouts
setup_user() {

  echo "Setting up docker-primary user..."

  local USER_NAME="docker-primary"
  if ! id "$USER_NAME" &>/dev/null; then
    adduser --disabled-password --gecos "" $USER_NAME
    echo "$USER_NAME:test" | chpasswd
  fi

  loginctl enable-linger docker-primary

  echo "docker-primary ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/docker-primary
}

install_packages
setup_user
