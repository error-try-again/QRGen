#!/bin/bash

#######################################
# Check if docker compose file exists
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
docker_compose_exists() {
  [[ -f ${DOCKER_COMPOSE_FILE} ]]
}
