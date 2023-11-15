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
    echo "docker-compose.yml exists. Attempting to stop containers with
    docker-compose..."
    docker compose -f "$docker_compose_file" down
  else
    echo "docker-compose.yml does not exist. Attempting to stop containers
    starting with 'qrgen'..."

    # Get all running containers that start with 'qrgen' and stop them
    docker ps --format '{{.Names}}' | grep '^qrgen' | xargs -r docker stop
  fi
}
