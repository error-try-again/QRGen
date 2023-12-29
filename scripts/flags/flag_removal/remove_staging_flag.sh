#!/usr/bin/env bash

set -euo pipefail

#######################################
# Strips the staging certbot command flag
# Additionally, backing up and replacing the original docker-compose.yml file
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
function remove_staging_flag() {
  local temp_file
  echo "Removing --staging flag from docker-compose.yml..."
  temp_file=$(remove_certbot_command_flags_compose '--staging')
  check_flag_removal "${temp_file}" '--staging'
  backup_and_replace_file "${DOCKER_COMPOSE_FILE}" "${temp_file}"
}
