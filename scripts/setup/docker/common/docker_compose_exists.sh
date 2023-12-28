#!/usr/bin/env bash

set -euo pipefail

#######################################
# Check if docker compose file exists
# Globals:
#   DOCKER_COMPOSE_FILE
# Arguments:
#  None
#######################################
docker_compose_exists() {
  [[ -f ${DOCKER_COMPOSE_FILE} ]]
}
