#!/bin/bash

setup_project_directories() {
  echo "Staging project directories..."
  local directory

  for directory in "$SERVER_DIR" "$FRONTEND_DIR" "$BACKEND_DIR" "$CERTBOT_DIR" "$PROJECT_LOGS_DIR"; do
    create_directory "$directory"
  done

  copy_server_files
}
