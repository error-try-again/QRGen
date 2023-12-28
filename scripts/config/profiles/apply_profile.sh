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
    local profile=$1  # The profile within the JSON file.
    local key=$2      # The specific key within the profile.
    jq -r ".$profile.$key" "$JSON_INSTALL_PROFILES"  # Use jq to parse and return the value.
}

#######################################
# Applies a configuration profile by setting global variables.
# This function iterates over keys in a given profile within the JSON configuration file,
# setting each as a global variable to its corresponding value. It handles boolean values explicitly.
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
    local profile=$1  # The name of the profile to apply.
    echo "Applying profile: $profile"

    # Retrieve the keys from the specified profile within the JSON file.
    local keys
    keys=$(jq -r ".$profile | keys | .[]" "$JSON_INSTALL_PROFILES")
    echo "Found keys in $profile: $keys"

    # Iterate over each key in the profile.
    local key
    for key in $keys; do
        local value
        # Retrieve the value for the current key from the profile.
        value=$(get_config_value "$profile" "$key")
        echo "Setting $key=$value"

        # Explicitly handle boolean values.
        case "$value" in
            true) value=true ;;
            false) value=false ;;
    esac

        # Declare the key-value pair as a global variable.
        # This is crucial for the profile to be picked up by the installer.
        # shellcheck disable=SC2034
        declare -g "$key=$value"
  done
}
