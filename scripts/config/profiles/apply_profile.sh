#!/usr/bin/env bash

set -euo pipefail

#######################################
# Retrieves a configuration data from a JSON file with the help of a key
# This function utilizes jq for JSON processing to extract the value of a specific key under a certain profile
# Arguments:
#   json_file: The JSON file name.
#   profile: The profile that the key falls under.
#   key: The identifier for the value that needs to be extracted.
#######################################
function get_config_value() {
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
    value=$(get_config_value "${json_file}" "${profile}" "${key}")

    # Declare the key-value pair as a global variable.
    # This is crucial for the profile to be picked up by the installer.
    declare -g "${key}=${value}"

    print_messages "Applied ${key}=${value}"
  done
}

#######################################
# Displays all profiles from the JSON config file
# and prompts the user to choose one to be applied.
# Globals:
#   output
#   profile
# Arguments:
#   json_file: The JSON file name.
#######################################
function select_and_apply_profile() {
  local json_file=$1

  validate_json_file "${json_file}"

  print_messages "Available profiles:"

  # Read profiles into an array
  local profiles
  output=$(jq -r 'keys | .[]' "${json_file}")
  readarray -t profiles <<< "${output}"

  # For each profile, print an index and the profile name to the console (starting at 1)
  local index=1
  for profile in "${profiles[@]}"; do
    echo "${index}) ${profile}"
    ((index++))
  done

  # Prompt the user to choose a profile
  local selection
  read -rp "Select a profile to apply [1-${#profiles[@]}]: " selection

  # Validate selection and apply profile
  if [[ ${selection} =~ ^[0-9]+$ ]] && [[ ${selection} -ge 1   ]] && [[ ${selection} -le ${#profiles[@]}   ]]; then
    local selected_profile=${profiles[selection - 1]}
    print_messages "You selected: ${selected_profile}"
    apply_profile "${json_file}" "${selected_profile}"
  else
    print_messages "Invalid selection: ${selection}"
    exit 1
  fi
}
