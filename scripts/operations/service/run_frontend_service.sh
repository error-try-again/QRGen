#!/usr/bin/env bash

set -euo pipefail

#######################################
# Builds and runs the frontend service using docker compose.
# Arguments:
#   1
#######################################
function docker_compose_frontend_service() {
  local cache_option
  cache_option="${1:-}"
  if [[ -n "${cache_option}" ]]; then
    docker compose --progress=plain build "${cache_option}" frontend
  else
    docker compose --progress=plain build frontend
  fi
  docker compose up -d frontend
}

#######################################
# Determines whether Docker's caching system should be used when building the Frontend service image.
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
function run_frontend_service() {
  if [[ -n ${DISABLE_DOCKER_CACHING} ]] && [[ ${DISABLE_DOCKER_CACHING} == 'true' ]]; then
    docker_compose_frontend_service '--no-cache'
  else
    docker_compose_frontend_service
  fi
}
