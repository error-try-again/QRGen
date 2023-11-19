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

  local containers_to_stop
  containers_to_stop=$(docker ps -a -q --filter "name=qrgen")

  if docker_compose_exists; then
    echo "Stopping containers using docker-compose..."
    docker compose -f "${PROJECT_ROOT_DIR}/docker-compose.yml" down
  fi

  if [ -n "$containers_to_stop" ]; then
    echo "Force stopping remaining 'qrgen' containers..."
    docker stop "${containers_to_stop}"
  else
    echo "No 'qrgen' containers to stop."
  fi
}
