#!/usr/bin/env bash

set -euo pipefail

#######################################
# Provides removal of the staging flag when running in production mode
# Globals:
#   USE_PRODUCTION_SSL
# Arguments:
#  None
#######################################
function handle_staging_flags() {
if [[ -n ${USE_PRODUCTION_SSL:-no} ]]; then
  print_messages "Certbot is running in production mode."
  print_messages "Removing --staging flag from docker-compose.yml..."
  remove_staging_flag
fi
}
