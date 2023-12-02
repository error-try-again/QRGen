#!/usr/bin/env bash

#######################################
# Stops the containers using docker compose
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
stop_containers() {
  test_docker_env
  if docker_compose_exists; then
    echo "Stopping containers using docker-compose..."
    docker compose -f "${DOCKER_COMPOSE_FILE}" down
  fi
}
