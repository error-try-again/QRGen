#!/usr/bin/env bash

set -euo pipefail

#######################################
# Validate the installer profile configuration file
# Globals:
#   json_file
# Arguments:
#   1
#######################################
function validate_json_file() {
  json_file="${1}"
  if [[ ! -f ${json_file}   ]]; then
    echo "Configuration file ${json_file} does not exist."
    exit 1
  fi
}
