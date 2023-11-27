#!/bin/bash

#######################################
# Ensures Docker environment variables are set.
# Critical for standard operation of Docker in rootless mode.
# Globals:
#   DOCKER_HOST
# Arguments:
#  None
#######################################
test_docker_env() {
  echo "Ensuring Docker environment variables are set..."
  local expected_docker_host
  # Update or set DOCKER_HOST.
  expected_docker_host="unix:///run/user/$(id -u)/docker.sock"
  if [ -z "${DOCKER_HOST:-}" ] || [ "${DOCKER_HOST:-}" != "${expected_docker_host}" ]; then
    DOCKER_HOST="${expected_docker_host}"
    export DOCKER_HOST
    echo "Set DOCKER_HOST to ${DOCKER_HOST}"
  fi
}
