#!/usr/bin/env bash

set -euo pipefail

#######################################
# Builds and runs the backend service using docker compose.
# Arguments:
#   1
#######################################
function docker_compose_backend_service() {
  local cache_option=$1
  print_messages "Building and running Backend service ${cache_option}..."
  if ! docker compose --progress=plain build "${cache_option}" backend; then
    print_messages "Failed to build Backend service."
    exit 1
  fi
  docker compose up -d backend
}

#######################################
# Determines whether Docker's caching system should be used when building the Backend service image.
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
function run_backend_service() {
  if [[ -n ${DISABLE_DOCKER_CACHING} ]]; then
    docker_compose_backend_service '--no-cache'
  else
    docker_compose_backend_service ''
  fi
}
