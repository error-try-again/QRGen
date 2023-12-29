#!/usr/bin/env bash

set -euo pipefail

#######################################
# Check if docker compose file exists
# Globals:
#   DOCKER_COMPOSE_FILE
# Arguments:
#  None
#######################################
function check_docker_compose() {
  [[ -f ${DOCKER_COMPOSE_FILE} ]]
}
