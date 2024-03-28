#!/usr/bin/env bash

set -euo pipefail

#######################################
# Stop containers using docker-compose
# Globals:
#   docker_compose_file
# Arguments:
#  None
#######################################
stop_containers() {
  verify_docker
  if check_docker_compose "${docker_compose_file}"; then
    print_message "Stopping containers using docker-compose..."
    docker compose -f "${docker_compose_file}" down
  fi
}