#!/usr/bin/env bash

#######################################
# Builds the custom Certbot service image.
# Globals:
#   DISABLE_DOCKER_CACHING
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
function build_certbot_service() {
  if [[ -n "${DISABLE_DOCKER_CACHING}" ]] && [[ "${DISABLE_DOCKER_CACHING}" == "true" ]]; then
    print_messages "Building Certbot service without caching..."
    if ! docker compose --progress=plain build --no-cache certbot; then
      print_messages "Failed to build Certbot service."
      return 1
    fi
  fi
}
