#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Ensures Docker environment variables are set.
# Critical for standard operation of Docker in rootless mode.
# Globals:
#   DOCKER_HOST
# Arguments:
#  None
#######################################
# bashsupport disable=BP2001
function test_docker_env() {
  print_messages "Ensuring Docker environment variables are set..."

  # Update or set DOCKER_HOST.
  local expected_docker_host
  expected_docker_host="unix:///run/user/$(id -u)/docker.sock"
  if [[ -z ${DOCKER_HOST:-} ]] || [[ ${DOCKER_HOST:-} != "${expected_docker_host}" ]]; then
    DOCKER_HOST="${expected_docker_host}"
    export DOCKER_HOST
    print_messages "Set DOCKER_HOST to ${DOCKER_HOST}"
  fi
}
