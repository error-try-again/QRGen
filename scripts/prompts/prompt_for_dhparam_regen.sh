#!/usr/bin/env bash

set -euo pipefail

#######################################
# Prompts the user to select whether they want to regenerate the SSL certificates/DH Parameters.
# Globals:
#   REGENERATE_SSL_CERTS
# Arguments:
#   1
# Returns:
#   0 ...
#   1 ...
#######################################
function prompt_for_dhparam_regeneration() {
  if [[ ${REGENERATE_SSL_CERTS} == "true" ]]; then
    return 0
  elif [[ ${REGENERATE_SSL_CERTS} == "false" ]]; then
    return 1
  fi
  local response
  read -rp "Do you want to regenerate the certificates in $1? [y/N]: " response
  if [[ ${response} =~ ^([yY][eE][sS]|[yY])$ ]]; then
    return 0
  else
    return 1
  fi
}
