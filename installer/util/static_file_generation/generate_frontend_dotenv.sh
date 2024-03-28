#!/usr/bin/env bash

set -euo pipefail

#######################################
# Generate the frontend .env file
# Arguments:
#   1
#   2
#######################################
generate_frontend_dotenv() {
  local frontend_dotenv_file="${1}"
  local use_google_api_key="${2}"
  cat << EOF > "${frontend_dotenv_file}"
use_google_api_key=${use_google_api_key}
EOF
}