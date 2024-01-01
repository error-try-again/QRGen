#!/usr/bin/env bash
# shellcheck disable=SC2034

set -euo pipefail

#######################################
# Retrieves a configuration data from a JSON file with the help of a key
# This function utilizes jq for JSON processing to extract the value of a specific key under a certain profile
# Arguments:
#   json_file: The JSON file name.
#   profile: The profile that the key falls under.
#   key: The identifier for the value that needs to be extracted.
#######################################
function extract_configuration_value() {
  local json_file=$1
  local profile=$2
  local key=$3

  if [[ $# -lt 3 ]]; then
    print_messages "Error: Not enough arguments"
    print_messages "Usage: get_config_value [json_file] [profile] [key]"
    exit 1
  fi

  jq -r ".${profile}.${key}" "${json_file}"
}
