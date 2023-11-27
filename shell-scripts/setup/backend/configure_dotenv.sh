#!/bin/bash

#######################################
# Configure the .env file for the backend
# Globals:
#   BACKEND_DIR
#   BACKEND_PORT
#   origin
# Arguments:
#  None
#######################################
configure_dot_env() {
  cat << EOF > "$BACKEND_DOTENV_FILE"
ORIGIN=$ORIGIN
PORT=$BACKEND_PORT
USE_SSL=$USE_SSL
EOF
}
