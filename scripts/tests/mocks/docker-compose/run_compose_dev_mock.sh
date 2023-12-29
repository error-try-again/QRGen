#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Mocks the docker compose development configuration (no ssl/letsencrypt)
# Globals:
#   DOCKER_COMPOSE_FILE
#   test_output_dir
# Arguments:
#  None
#######################################
function run_compose_dev_mock() {
  echo "---------------------------------------"
  echo "Simulating Docker Compose configuration for http only..."

  setup_dev_mock_parameters

  configure_docker_compose 2>&1 | tee "${test_output_dir}/compose_dev_output.log"

  # Check for errors in the output and log them
  local compose_output
  compose_output=$(< "${test_output_dir}/compose_dev_output.log")

  log_mock_error "${compose_output}"

  validate_service_config "${DOCKER_COMPOSE_FILE}" "docker"
}
