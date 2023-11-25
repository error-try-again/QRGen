#!/bin/bash

# Generates project directory structure.
setup_project_directories() {
  echo "Staging project directories..."
  local directory

  for directory in "$SERVER_DIR" "$CERTBOT_DIR" "$PROJECT_LOGS_DIR"; do
    create_directory "$directory"
  done

  retrieve_submodules
}
