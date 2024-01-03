#!/usr/bin/env bash

set -euo pipefail

#######################################
# Builds and runs the backend service using docker compose.
# Arguments:
#   1
#######################################
function docker_compose_backend_service() {
  local cache_option
  cache_option="${1:-}"
  if [[ -n "${cache_option}" ]]; then
    docker compose --progress=plain build "${cache_option}" backend;
  else
    docker compose --progress=plain build backend;
  fi
}

#######################################
# Determines whether Docker's caching system should be used when building the Backend service image.
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
function run_backend_service() {
  if [[ -n ${DISABLE_DOCKER_CACHING} ]] && [[ ${DISABLE_DOCKER_CACHING} == 'true' ]]; then
    docker_compose_backend_service '--no-cache'
  else
    docker_compose_backend_service
  fi
}
