#!/usr/bin/env bash

set -euo pipefail

#######################################
# Function to remove containers that conflict with Docker Compose services
# Globals:
#   PWD
# Arguments:
#  None
#######################################
function remove_conflicting_containers() {
  # Extract service names from docker-compose.yml
  local service_names
  service_names=$(docker compose config --services)

  # Loop through each service name to check if corresponding container exists
  local service
  for service in ${service_names}; do
    # Generate the probable container name based on the folder name and service name
    # e.g. In this instance, since the project name is "QRGen" and the service
    # name is "backend", the probable container name would be "QRGen_backend_1"
    local probable_container_name="${PWD##*/}_${service}_1"

    # Check if a container with the generated name exists
    if docker ps -a --format '{{.Names}}' | grep -qw "${probable_container_name}"; then
      print_messages "Removing existing container that may conflict: ${probable_container_name}"
      docker rm -f "${probable_container_name}"
    else
      print_messages "No conflict for ${probable_container_name}"
    fi
  done
}
