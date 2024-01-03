#!/usr/bin/env bash

set -euo pipefail

#######################################
# Stops the containers using docker compose
# Globals:
#   DOCKER_COMPOSE_FILE
# Arguments:
#  None
#######################################
function stop_containers() {
  test_docker_env
  if check_docker_compose; then
    print_messages "Stopping containers using docker-compose..."
    docker compose -f "${DOCKER_COMPOSE_FILE}" down
  fi
}
