#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Mocks the Certbot Dockerfile configuration
#######################################
function run_dockerfile_certbot_mock() {
  echo "---------------------------------------"
  echo "Simulating Certbot Dockerfile configuration..."

  setup_letsencrypt_mock_parameters

  CERTBOT_DOCKERFILE="${test_output_dir}/Certbot.Dockerfile"

  configure_certbot_docker 2>&1 | tee "${test_output_dir}/certbot_docker_output.log"

  # Check for errors in the output and log them
  local docker_output
  docker_output=$(< "${test_output_dir}/certbot_docker_output.log")

  log_mock_error "${docker_output}"
}
