#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Setup common configuration parameters for NGINX and Docker Compose
# Globals:
#   BACKEND_PORT
#   DNS_RESOLVER
#   DOMAIN_NAME
#   EXPOSED_NGINX_PORT
#   NGINX_SSL_PORT
#   NODE_VERSION
#   RELEASE_BRANCH
#   SUBDOMAIN
#   TIMEOUT
# Arguments:
#  None
#######################################
function setup_common_mock_parameters() {
  local default_root="${PROJECT_ROOT_DIR:-$(pwd)}"
  test_output_dir="${default_root}/mocks"

  # Create directories if they don't exist
  mkdir -p "${test_output_dir}"
  mkdir -p "${test_output_dir}/logs"
  mkdir -p "${test_output_dir}/run"

  # Ensure log and pid files exist
  touch "${test_output_dir}/logs/error.log"
  touch "${test_output_dir}/run/nginx.pid"

  BACKEND_PORT=12345
  BACKEND_UPSTREAM_NAME="localhost"
  NGINX_PID="pid ${PROJECT_ROOT_DIR}/nginx.pid;"
  NGINX_ERROR_LOG="error_log ${test_output_dir}/logs/error.log warn;"
  NGINX_ACCESS_LOG="access_log ${test_output_dir}/logs/access.log;"
  RELEASE_BRANCH="full-release"
  NODE_VERSION="latest"
  NGINX_SSL_PORT="443"
  EXPOSED_NGINX_PORT=8080
  DNS_RESOLVER="8.8.8.8"
  TIMEOUT="5"
  DOMAIN_NAME="example.com"
  SUBDOMAIN="test"
}
