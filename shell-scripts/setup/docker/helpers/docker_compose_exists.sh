#!/bin/bash

#######################################
# description
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
docker_compose_exists() {
  [[ -f ${DOCKER_COMPOSE_FILE} ]]
}
