#!/usr/bin/env bash

set -euo pipefail

#######################################
# Builds and runs the frontend service
# Checks to see if caching is disabled, and builds accordingly
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
function run_frontend_service() {
  if [[ -n ${DISABLE_DOCKER_CACHING} ]]; then
    print_messages "Building frontend service with caching disabled..."
    if ! docker compose --progress=plain build --no-cache frontend; then
      print_messages "Failed to build Frontend service."
      exit 1
    fi
    print_messages "Running Frontend service..."
    docker compose up -d frontend 2>&1 | grep -Po 'port \K\d+' | xargs -I {} lsof -i :{} -S
  else
    print_messages "Building frontend service..."
    if ! docker compose --progress=plain build frontend; then
      print_messages "Failed to build Frontend service."
      exit 1
    fi
    print_messages "Running Frontend service..."
    docker compose up -d frontend 2>&1 | grep -Po 'port \K\d+' | xargs -I {} lsof -i :{} -S
  fi
}
