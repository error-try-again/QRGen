#!/bin/bash


#######################################
# Generates project directory structure.
# Globals:
#   BACKEND_DIR
#   CERTBOT_DIR
#   FRONTEND_DIR
#   PROJECT_LOGS_DIR
#   SERVER_DIR
# Arguments:
#  None
#######################################
setup_project_directories() {
  echo "Staging project directories..."
  local directory

  for directory in "$SERVER_DIR" "$FRONTEND_DIR" "$BACKEND_DIR" "$CERTBOT_DIR" "$PROJECT_LOGS_DIR"; do
    create_directory "$directory"
  done
}
