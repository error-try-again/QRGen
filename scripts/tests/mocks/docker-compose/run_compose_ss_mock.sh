#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Mocks the docker compose self signed certificate configuration
# Globals:
#   DOCKER_COMPOSE_FILE
#   USE_LETSENCRYPT
#   USE_SELF_SIGNED_CERTS
#   test_output_dir
# Arguments:
#  None
#######################################
function run_compose_ss_mock() {
  echo "---------------------------------------"
  echo "Simulating Docker Compose configuration with self-signed certificates..."

  setup_self_signed_mock_parameters

  DOCKER_COMPOSE_FILE="${test_output_dir}/docker-compose-ss.yml"

  generate_file_paths "${DOCKER_COMPOSE_FILE}"

  configure_docker_compose 2>&1 | tee "${test_output_dir}/compose_ss_output.log"

  # Check for errors in the output and log them
  local compose_output
  compose_output=$(<"${test_output_dir}/compose_ss_output.log")

  log_mock_error "${compose_output}"

  validate_service_config "${DOCKER_COMPOSE_FILE}" "docker"
}
