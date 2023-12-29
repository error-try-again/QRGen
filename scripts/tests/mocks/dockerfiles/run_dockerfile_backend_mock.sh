#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Mocks Backend/Express Dockerfile configuration
#######################################
function run_dockerfile_backend_mock() {
  echo "---------------------------------------"
  echo "Simulating backend Dockerfile configuration..."

  setup_dev_mock_parameters

  configure_backend_docker 2>&1 | tee "${test_output_dir}/backend_docker_output.log"

  # Check for errors in the output and log them
  local docker_output
  docker_output=$(< "${test_output_dir}/backend_docker_output.log")

  log_mock_error "${docker_output}"
}
