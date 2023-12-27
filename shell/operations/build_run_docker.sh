#!/usr/bin/env bash

set -euo pipefail

#######################################
# ---- Build and Run Docker ---- #
# Globals:
#   PROJECT_ROOT_DIR
#   USE_AUTO_RENEW_SSL
#   RELEASE_BRANCH
# Arguments:
#  None
#######################################
build_and_run_docker() {
    echo "Building and running Docker services..."

   # Perform pre-flight, and run Docker services, e.g. backend, frontend, etc.
    common_build_operations || {
      echo "Failed common build operations"
      exit 1
  }

    if [[ $BUILD_CERTBOT_IMAGE ]]; then
      echo "Building Certbot service..."
      run_certbot_service
  fi
    if [[ $USE_AUTO_RENEW_SSL ]]; then
      echo "Using auto-renewal for SSL certificates."
      generate_certbot_renewal_job
  fi

    # Dump logs or any other post-run operations
    dump_logs || {
      echo "Failed to dump logs"
      exit 1
  }
}
