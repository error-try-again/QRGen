#!/usr/bin/env bash

set -euo pipefail

#######################################
# Generates network definition for Docker Compose.
# Arguments:
#   1
#   2
#######################################
create_network_definition() {
  local network_name="$1"
  local network_driver="$2"

  local definition
  definition="networks:"
  definition+=$'\n'
  definition+="  ${network_name}:"
  definition+=$'\n'
  definition+="    driver: ${network_driver}"

  echo "${definition}"
}
