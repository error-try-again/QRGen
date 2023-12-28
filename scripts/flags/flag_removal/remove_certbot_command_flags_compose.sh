#!/usr/bin/env bash

set -euo pipefail

#######################################
# Modifies the docker-compose.yml file to remove specified flags
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#   1 - Flag to remove
# Returns:
#   Path to the temporary modified file
#######################################
function remove_certbot_command_flags_compose() {
  local flag_to_remove=$1
  local temp_file
  temp_file="$(mktemp)"

  # Perform the modification
  sed "/certbot:/,/command:/s/$flag_to_remove//" "$DOCKER_COMPOSE_FILE" > "$temp_file"

  # Output only the path to the temporary file
  echo "$temp_file"
}
