#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Run a series of configuration mocks (automatically test the configuration scripts)
# Globals:
#   PROJECT_ROOT_DIR
#   test_output_dir
# Arguments:
#  None
#######################################
function run_mocks() {
  local separator="---------------------------------------"
  local initial_message="| Running mocks..."
  local nginx_section_message="| Running NGINX Configuration mocks..."
  local compose_section_message="| Running Docker Compose Configuration mocks..."
  local dockerfile_section_message="| Running Dockerfile Configuration mocks..."
  local mocks_complete_message="| Mocks complete."

  echo "${separator}"
  echo "${initial_message}"
  echo "${separator}"

  # Setup common configuration parameters
  setup_common_mock_parameters

  # Run the upstream mock server
  mock_upstream_server

  # Build the various configuration files for NGINX and Docker Compose

  echo "${separator}"
  echo "${nginx_section_message}"

  run_nginx_ss_mock
  run_nginx_le_mock
  run_nginx_dev_mock

  echo "${separator}"
  echo "${compose_section_message}"

  run_compose_ss_mock
  run_compose_le_mock
  run_compose_dev_mock

  echo "${separator}"
  echo "${dockerfile_section_message}"

  run_dockerfile_backend_mock
  run_dockerfile_frontend_mock
  run_dockerfile_certbot_mock

  gracefully_terminate_mock_server

  echo "${separator}"
  echo "${mocks_complete_message}"
  echo "${separator}"
}
