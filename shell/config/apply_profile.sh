#!/usr/bin/env bash

set -euo pipefail

#######################################
# Read a configuration value from the JSON installer profile
# Globals:
#   CONFIG_FILE
# Arguments:
#   1
#   2
#######################################
get_config_value() {
    local profile=$1
    local key=$2
    jq -r ".$profile.$key" "$JSON_INSTALL_PROFILES"
}

#######################################
# Applies an installer configuration profile
# Globals:
#   $key=$value
#   CONFIG_FILE
# Arguments:
#   1
#######################################
# bashsupport disable=BP2001
apply_profile() {
    local profile=$1
    echo "Applying profile: $profile"

    # Get the keys within the specified profile only
    local keys
    keys=$(jq -r ".$profile | keys | .[]" "$JSON_INSTALL_PROFILES")
    echo "Found keys in $profile: $keys"

    local key
    for key in $keys; do
        local value
        # Get the value for the key within the specified profile
        value=$(get_config_value "$profile" "$key")
        echo "Setting $key=$value"

        # Check for boolean values and handle them appropriately
        case "$value" in
            true) value=true ;;
            false) value=false ;;
        esac

        # Declare the configuration globally
        # This is crucial for the profile to be picked up by the installer as it assigns whatever value is in the profile to the corresponding global variable
        # shellcheck disable=SC2034
        declare -g "$key=$value"
    done
}
