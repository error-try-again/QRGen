#!/bin/bash

#######################################
# description
# Globals:
#   BACKEND_DIR
#   CERTBOT_DIR
#   FRONTEND_DIR
#   HOME
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

  local src_dir="$HOME/QRGen/src"

  if [[ -d $src_dir   ]]; then
    copy_server_files
  else
    echo "Error: $src_dir does not exist. Attempting to create."
    if mkdir -p "$src_dir"; then
      echo "Source directory $src_dir created."
      copy_server_files
    else
      echo "Error: Failed to create $src_dir"
      exit 1
    fi
  fi
}
