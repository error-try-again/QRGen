#!/usr/bin/env bash

set -euo pipefail

#######################################
# Strips the dry run certbot command flag
# Additionally, backing up and replacing the original docker-compose.yml file
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
function remove_dry_run_flag() {
  local temp_file
  print_messages "Removing --dry-run flag from docker-compose.yml..."
  temp_file=$(remove_certbot_command_flags_compose '--dry-run')
  check_flag_removal "${temp_file}" '--dry-run'
  backup_and_replace_file "${DOCKER_COMPOSE_FILE}" "${temp_file}"
}
