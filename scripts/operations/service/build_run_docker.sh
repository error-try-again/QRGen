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
function build_and_run_docker() {
  print_messages "Building and running Docker services..."
  # Perform pre-flight, and run Docker services, e.g. backend, frontend, etc.
  common_build_operations || {
    print_messages "Failed common build operations"
    exit 1
  }
  if [[ -n ${BUILD_CERTBOT_IMAGE} ]]; then
    print_messages "Building Certbot service..."
    run_certbot_service
  fi
  if [[ -n ${USE_AUTO_RENEW_SSL} ]]; then
    print_messages "Using auto-renewal for SSL certificates."
    generate_certbot_renewal_job
  fi

  # Dump logs or any other post-run operations
  dump_logs || {
    print_messages "Failed to dump logs"
    exit 1
  }
}
