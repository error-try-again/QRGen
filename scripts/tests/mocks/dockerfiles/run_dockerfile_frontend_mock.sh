#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Mocks Frontend/React Dockerfile configuration
#######################################
function run_dockerfile_frontend_mock() {
  echo "---------------------------------------"
  echo "Simulating frontend Dockerfile configuration..."

  FRONTEND_DOCKERFILE="${test_output_dir}/Frontend.Dockerfile"

  generate_file_paths "${FRONTEND_DOCKERFILE}"

  configure_frontend_docker 2>&1 | tee "${test_output_dir}/frontend_docker_output.log"

  # Check for errors in the output and log them
  local docker_output
  docker_output=$(<"${test_output_dir}/frontend_docker_output.log")

  log_mock_error "${docker_output}"
}
