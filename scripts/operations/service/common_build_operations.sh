#!/usr/bin/env bash

set -euo pipefail

#######################################
# Performs common build operations
# Globals:
#   PROJECT_ROOT_DIR
#   RELEASE_BRANCH
# Arguments:
#  None
#######################################
function common_build_operations() {
  cd "${PROJECT_ROOT_DIR}" || {
    echo "Failed to change directory to ${PROJECT_ROOT_DIR}"
    exit 1
  }

  pre_flight || {
    echo "Failed pre-flight checks"
    exit 1
  }

  # If Docker Compose is running, bring down the services
  # Ensure that old services are brought down before proceeding
  if docker compose ps &>/dev/null; then
    echo "Bringing down existing Docker Compose services..."
    docker compose down || {
      echo "Failed to bring down existing Docker Compose services"
      exit 1
    }
  fi

  handle_certs || {
    echo "Failed to handle certs"
    exit 1
  }

  # Run each service separately - must be active for certbot to work
  if [[ ${RELEASE_BRANCH} = "full-release" ]]; then
    run_backend_service
    run_frontend_service
  else
    run_frontend_service
  fi
}
