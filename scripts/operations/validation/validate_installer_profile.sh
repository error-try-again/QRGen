#!/usr/bin/env bash

set -euo pipefail

#######################################
# Ensure the JSON configuration file exists
# Globals:
#   CONFIG_FILE
#   JSON_INSTALL_PROFILES
# Arguments:
#  None
#######################################
function validate_installer_profile_configuration() {
  # Ensure the configuration file exists
  if [[ ! -f "${JSON_INSTALL_PROFILES}" ]]; then
    echo "Configuration file ${JSON_INSTALL_PROFILES} does not exist."
    exit 1
  fi
}
