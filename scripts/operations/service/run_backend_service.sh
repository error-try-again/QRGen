#!/usr/bin/env bash

set -euo pipefail

#######################################
# Builds and runs the backend service
# Checks to see if caching is disabled, and builds accordingly
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
function run_backend_service() {
  if [[ -n ${DISABLE_DOCKER_CACHING} ]]; then
    echo "Building and running Backend service without caching..."
    if ! docker compose --progress=plain build --no-cache backend; then
      echo "Failed to build Backend service."
      exit 1
    fi
    docker compose up -d backend
  else
    echo "Building and running Backend service..."
    if ! docker compose --progress=plain build backend; then
      echo "Failed to build Backend service."
      exit 1
    fi
    docker compose up -d backend
  fi
}
