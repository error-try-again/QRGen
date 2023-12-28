#!/usr/bin/env bash

set -euo pipefail

#######################################
# Configure the .env file for the backend
# Globals:
#   BACKEND_DOTENV_FILE
#   BACKEND_PORT
#   GOOGLE_API_KEY
#   ORIGIN
#   USE_SSL
# Arguments:
#  None
#######################################
function configure_backend_dotenv() {
  echo "Configuring backend .env file"
  cat << EOF > "$BACKEND_DOTENV_FILE"
ORIGIN=$ORIGIN
PORT=$BACKEND_PORT
USE_SSL=$USE_SSL
GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY
EOF
}
