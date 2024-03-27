#!/usr/bin/env bash

set -euo pipefail

#######################################
# Generate the backend dotenv file with the provided configuration values/environment variables
# Arguments:
#   1
#   2
#   3
#   4
#######################################
generate_backend_dotenv() {
  local backend_dotenv_file="${1}"
  local google_maps_api_key="${2}"
  local origin_url="${3}"
  local use_ssl_flag="${4}"

  print_message "Configuring backend .env file"
  cat << EOF > "${backend_dotenv_file}"
ORIGIN=https://localhost
USE_SSL=${use_ssl_flag}
GOOGLE_MAPS_API_KEY=${google_maps_api_key}
EOF
}