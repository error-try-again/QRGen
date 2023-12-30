#!/usr/bin/env bash

set -euo pipefail

#######################################
# Retrieves a specific configuration value from a JSON file.
# This function uses jq to parse a JSON file and extract the value corresponding to a given key within a specified profile.
# Globals:
#   JSON_INSTALL_PROFILES - Expected to be the path to a JSON file containing installation profiles.
# Arguments:
#   1: profile (string) - The profile name within the JSON file.
#   2: key (string) - The key within the profile whose value should be retrieved.
# Outputs:
#   The value from the JSON file for the specified key within the given profile.
#######################################
function get_config_value() {

  if [[ $# -lt 2 ]]; then
    echo "Error: Not enough arguments"
    echo "Usage: get_config_value [profile] [key]"
    exit 1
  fi

  local profile=$1 # The profile within the JSON file.
  local key=$2     # The specific key within the profile.

  jq -r ".${profile}.${key}" "${JSON_INSTALL_PROFILES}" # Use jq to parse and return the value.
}

#######################################
# Applies a configuration profile by setting global variables.
# This function iterates over keys in a given profile within the JSON configuration file,
# setting each as a global variable to its corresponding value.
# Globals:
#   JSON_INSTALL_PROFILES - Path to the JSON file containing installer profiles.
# Arguments:
#   1: profile (string) - The name of the profile to apply.
# Outputs:
#   Informational messages about the profile application process.
# Note:
#   It's crucial that JSON_INSTALL_PROFILES is correctly set to the path of the JSON configuration file before this function is called.
#######################################
function apply_profile() {

  if [[ $# -lt 1 ]]; then
    echo "Error: Not enough arguments"
    echo "Usage: apply_profile [profile]"
    exit 1
  fi

  local profile=$1 # The name of the profile to apply.
  echo "Applying profile: ${profile}"

  # Retrieve the keys from the specified profile within the JSON file.
  local keys
  keys=$(jq -r ".${profile} | keys | .[]" "${JSON_INSTALL_PROFILES}")

  # Iterate over each key in the profile.
  local key
  for key in ${keys}; do
    local value

    # Retrieve the value for the current key from the profile.
    value=$(get_config_value "${profile}" "${key}")

    # Declare the key-value pair as a global variable.
    # This is crucial for the profile to be picked up by the installer.
    declare -g "$key=$value"

    echo "Applied ${key}=${value}"
  done
}

#######################################
# Lists all profiles from the JSON configuration file and prompts the user to select one to apply.
# Globals:
#   JSON_INSTALL_PROFILES - Path to the JSON file containing installer profiles.
# Outputs:
#   Prompts and informational messages about the profile selection and application process.
#######################################
function select_and_apply_profile() {
  echo "Available profiles:"

  # Read profiles into an array
  local profiles
  readarray -t profiles < <(jq -r 'keys | .[]' "${JSON_INSTALL_PROFILES}")

  # Display options
  local index=1
  for profile in "${profiles[@]}"; do
    echo "${index}) ${profile}"
    ((index++))
  done

  # Prompt the user to choose a profile
  local selection
  read -rp "Select a profile to apply [1-${#profiles[@]}]: " selection

  # Validate selection and apply profile
  if [[ ${selection} =~ ^[0-9]+$ ]] && [[ "${selection}" -ge 1 ]] && [[ "${selection}" -le ${#profiles[@]} ]]; then
    local selected_profile=${profiles[${selection} - 1]}
    echo "You selected: ${selected_profile}"
    apply_profile "${selected_profile}"
  else
    echo "Invalid selection. Please try again."
    exit 1
  fi
}
