#!/bin/bash

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
configure_dot_env() {
  cat << EOF > "$BACKEND_DOTENV_FILE"
ORIGIN=$ORIGIN
PORT=$BACKEND_PORT
USE_SSL=$USE_SSL
USE_GOOGLE_API=$USE_GOOGLE_API_KEY
GOOGLE_API_KEY=$GOOGLE_API_KEY
EOF
}
