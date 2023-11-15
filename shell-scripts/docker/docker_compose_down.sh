#!/bin/bash

#######################################
# description
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
stop_containers() {
  test_docker_env

  local docker_compose_file="$PROJECT_ROOT_DIR/docker-compose.yml"

  if [[ -f $docker_compose_file ]]; then
    echo "docker-compose.yml exists. Attempting to stop containers with docker-compose..."
    docker compose -f "$docker_compose_file" down

    # Re-check if any containers are still running
    if docker ps -a | grep -q 'qrgen'; then
      echo "Some containers are still running. Attempting to force stop..."
      docker ps -a | grep 'qrgen' | awk '{print $1}' | xargs -r docker stop
    else
      echo "No containers to stop."
    fi
  else
    echo "docker-compose.yml does not exist. Stopping all Docker containers starting with 'qrgen'..."
    if docker ps -a | grep -q 'qrgen'; then
      docker ps -a | grep 'qrgen' | awk '{print $1}' | xargs -r docker stop
    else
      echo "No 'qrgen' containers to stop."
    fi
  fi
}
