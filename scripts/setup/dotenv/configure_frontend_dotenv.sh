#!/usr/bin/env bash

set -euo pipefail

#######################################
# Configure the .env file for the frontend
# Globals:
#   FRONTEND_DOTENV_FILE
#   GOOGLE_MAPS_API_KEY
# Arguments:
#  None
#######################################
function configure_frontend_dotenv() {
  cat << EOF > "${FRONTEND_DOTENV_FILE}"
USE_GOOGLE_API_KEY=${USE_GOOGLE_API_KEY}
EOF
}
