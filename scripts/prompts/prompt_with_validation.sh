#!/usr/bin/env bash

set -euo pipefail

#######################################
#  Handles user input for their provided domain name/subdomain.
# Arguments:
#   1
#   2
#######################################
function prompt_with_validation() {
  local prompt_message="$1"
  local error_message="$2"
  local user_input=""
  while true; do
    read -rp "${prompt_message}" user_input
    if [[ -n ${user_input} ]]; then
      echo "${user_input}"
      break
else
      echo "${error_message}"
fi
  done
}
