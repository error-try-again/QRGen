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
  if docker_compose_exists; then
    echo "Stopping containers using docker-compose..."
    docker compose -f "${PROJECT_ROOT_DIR}/docker-compose.yml" down
  fi
}
