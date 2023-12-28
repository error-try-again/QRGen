#!/usr/bin/env bash

set -euo pipefail

#######################################
# Generates volume definition for Docker Compose.
# Globals:
#   USE_LETSENCRYPT
#   USE_SELF_SIGNED_CERTS
# Arguments:
#   1
#   2
#######################################
create_volume_definition() {
  local volume_name="$1"
  local volume_driver="$2"
  if [[ $USE_LETSENCRYPT == "true" ]] || [[ $USE_SELF_SIGNED_CERTS == "true" ]]; then
    local definition
    definition="volumes:"
    definition+=$'\n'
    definition+="  ${volume_name}:"
    definition+=$'\n'
    definition+="    driver: ${volume_driver}"
    echo "$definition"
  fi
}
