#!/usr/bin/env bash

set -euo pipefail

#######################################
# Stops, removes Docker containers, images, volumes, and networks starting with 'qrgen'.
# Globals:
#   None
# Arguments:
#  None
#######################################
purge_builds() {
  test_docker_env

  echo "Identifying and purging Docker resources associated with 'qrgen'..."

  # Stop and remove containers
  if docker ps -a --format '{{.Names}}' | grep -q '^qrgen'; then
    echo "Stopping and removing 'qrgen' containers..."
    docker ps -a --format '{{.Names}}' | grep '^qrgen' | xargs -r docker stop
    docker ps -a --format '{{.Names}}' | grep '^qrgen' | xargs -r docker rm
  else
    echo "No 'qrgen' containers found."
  fi

  # Remove images
  if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^qrgen'; then
    echo "Removing 'qrgen' images..."
    docker images --format '{{.Repository}}:{{.Tag}}' | grep '^qrgen' | xargs -r docker rmi --force
  else
    echo "No 'qrgen' images found."
  fi

  # Remove volumes
  if docker volume ls --format '{{.Name}}' | grep -q '^qrgen'; then
    echo "Removing 'qrgen' volumes..."
    docker volume ls --format '{{.Name}}' | grep '^qrgen' | xargs -r docker volume rm --force
  else
    echo "No 'qrgen' volumes found."
  fi

  # Remove networks
  if docker network ls --format '{{.Name}}' | grep -q '^qrgen'; then
    echo "Removing 'qrgen' networks..."
    docker network ls --format '{{.Name}}' | grep '^qrgen' | xargs -r docker network rm --force
  else
    echo "No 'qrgen' networks found."
  fi
}
