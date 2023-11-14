#!/bin/bash

#######################################
# description
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
docker_compose_exists() {
  [[ -f "${PROJECT_ROOT_DIR}/docker-compose.yml" ]]
}
