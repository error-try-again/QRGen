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
    echo "docker-compose.yml does not exist. Stopping all Docker containers starting with 'qrgen'..."

    if [[ $(docker ps -a | grep -c qrgen) -gt 0 ]]; then
      docker ps -a | grep qrgen | awk '{print $1}' | xargs docker stop
    else
      echo "No containers to stop."
    fi

  fi
}
