#!/usr/bin/env bash

set -euo pipefail

#######################################
# Builds and runs the Certbot service using docker compose.
# Arguments:
#   1
#######################################
function docker_compose_certbot_service() {
  local cache_option
  cache_option="${1:-}"
  if [[ -n "${cache_option}" ]]; then
    docker compose --progress=plain build "${cache_option}" certbot;
  else
    docker compose --progress=plain build certbot;
  fi
}

#######################################
# Determines whether Docker's caching system should be used when building the Certbot service image.
# Globals:
#   DISABLE_DOCKER_CACHING
# Arguments:
#  None
#######################################
function run_certbot_service() {
  if [[ -n ${DISABLE_DOCKER_CACHING} ]] && [[ ${DISABLE_DOCKER_CACHING} == 'true' ]]; then
    docker_compose_certbot_service '--no-cache'
  else
    docker_compose_certbot_service
  fi
}
