#!/usr/bin/env bash

set -euo pipefail

#######################################
# Builds and runs the Certbot service using docker compose.
# Arguments:
#   1
#######################################
function build_certbot_service() {
  local cache_option
  cache_option="${1:-}"
  if [[ -n "${cache_option}" ]]; then
    docker compose --progress=plain build "${cache_option}" certbot
  else
    docker compose --progress=plain build certbot
  fi
}

#######################################
# Determines whether Docker's caching system should be used when building the Certbot service image.
# Globals:
#   DISABLE_DOCKER_CACHING
# Arguments:
#  None
#######################################
function handle_certbot_build_and_caching() {
  if [[ -n ${DISABLE_DOCKER_CACHING} ]] && [[ ${DISABLE_DOCKER_CACHING} == 'true' ]]; then
    build_certbot_service '--no-cache'
  else
    build_certbot_service
  fi
}
