#!/usr/bin/env bash

set -euo pipefail

#######################################
# Stops, removes Docker containers, images, volumes, and networks starting with 'qrgen'.
# Globals:
#   None
# Arguments:
#  None
#######################################
function purge() {
  test_docker_env

  print_messages "Identifying and purging Docker resources associated with 'qrgen'..."

  # Stop and remove containers
  if docker ps -a --format '{{.Names}}' | grep -q '^qrgen'; then
    print_messages "Stopping and removing 'qrgen' containers..."
    docker ps -a --format '{{.Names}}' | grep '^qrgen' | xargs -r docker stop
    docker ps -a --format '{{.Names}}' | grep '^qrgen' | xargs -r docker rm
  else
    print_messages "No 'qrgen' containers found."
  fi

  # Remove images
  if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^qrgen'; then
    print_messages "Removing 'qrgen' images..."
    docker images --format '{{.Repository}}:{{.Tag}}' | grep '^qrgen' | xargs -r docker rmi --force
  else
    print_messages "No 'qrgen' images found."
  fi

  # Remove volumes
  if docker volume ls --format '{{.Name}}' | grep -q '^qrgen'; then
    print_messages "Removing 'qrgen' volumes..."
    docker volume ls --format '{{.Name}}' | grep '^qrgen' | xargs -r docker volume rm --force
  else
    print_messages "No 'qrgen' volumes found."
  fi

  # Remove networks
  if docker network ls --format '{{.Name}}' | grep -q '^qrgen'; then
    print_messages "Removing 'qrgen' networks..."
    docker network ls --format '{{.Name}}' | grep '^qrgen' | xargs -r docker network rm --force
  else
    print_messages "No 'qrgen' networks found."
  fi
}
