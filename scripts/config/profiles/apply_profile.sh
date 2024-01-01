#!/usr/bin/env bash
# shellcheck disable=SC2034

set -euo pipefail

#######################################
# Applies a profile configuration by setting global variable pairs.
# Cycles through all keys in a specific profile
# within the JSON config file, setting each to a global variable mapped to its respective value.
# Globals:
#   ${key}=${value}
# Arguments:
#   1
#   2
#######################################
function apply_profile() {
  shopt -s inherit_errexit

  local json_file=$1
  local profile=$2

  if [[ $# -lt 2 ]]; then
    print_messages "Error: Not enough arguments"
    print_messages "Usage: apply_profile [json_file] [profile]"
    exit 1
  fi

  print_messages "Applying profile: ${profile}"

  # The 'jq' command is used to parse JSON data. The '-r' option outputs raw strings instead of JSON-encoded ones.
  # ".${profile} | keys | .[]" is a filter that finds the keys of the object at the path specified by '${profile}',
  # and outputs them one per line. These keys are then stored in the 'keys' variable.
  # "${json_file}" is the JSON file being processed.
  local keys
  keys=$(jq -r ".${profile} | keys | .[]" "${json_file}")

  # Iterate over each key in the profile.
  local key
  for key in ${keys}; do
    local value

    # Retrieve the value for the current key from the profile.
    value=$(extract_configuration_value "${json_file}" "${profile}" "${key}")

    # Declare the key-value pair as a global variable, since the key should reference an ENV variable.
    # This is crucial for the profile to be picked up by the installer.
    # Shellcheck will complain about this since it cannot statically analyze the variable name - which is why SC2034 is disabled.
    # bashsupport disable=BP2001
    declare -g "${key}=${value}"

    print_messages "Applied ${key}=${value}"
done
}
