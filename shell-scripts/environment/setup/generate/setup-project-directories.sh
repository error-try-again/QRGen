#!/bin/bash

setup_project_directories() {
  echo "Staging project directories..."

  local directory
  for directory in "$SERVER_DIR" "$FRONTEND_DIR" "$BACKEND_DIR" "$CERTBOT_DIR"; do
    create_directory "$directory"
  done

  local SRC_DIR="$HOME/QRGen-FullStack/src"

  if [[ -d "$SRC_DIR" ]]; then
    copy_server_files
  else
    echo "Error: $SRC_DIR does not exist. Attempting to create."
    if mkdir -p "$SRC_DIR"; then
      echo "Source directory $SRC_DIR created."
      copy_server_files
    else
      echo "Error: Failed to create $SRC_DIR"
      exit 1
    fi
  fi
}
