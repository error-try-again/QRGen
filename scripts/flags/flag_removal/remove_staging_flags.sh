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
  if [[ ${USE_PRODUCTION_SSL:-no} ]]; then
    echo "Certbot is running in production mode."
    echo "Removing --staging flag from docker-compose.yml..."
    remove_staging_flag
  fi
}
