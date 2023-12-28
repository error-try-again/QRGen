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
run_frontend_service() {
    if [[ $DISABLE_DOCKER_CACHING ]]; then
     echo "Building and running Frontend service without caching..."
      if ! docker compose --progress=plain build --no-cache frontend; then
          echo "Failed to build Frontend service."
          exit 1
    fi
      docker compose up -d frontend
  else
      echo "Building and running Frontend service..."
      if ! docker compose --progress=plain build frontend; then
          echo "Failed to build Frontend service."
          exit 1
    fi
      docker compose up -d frontend
  fi
}
