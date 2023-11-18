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
  local server_src_dir="$src_dir/server"

  if [[ -d $src_dir && -d $server_src_dir  ]]; then
    copy_server_files
  else
    echo "Error: Sources are not available, exiting..."
    exit 1
  fi
}
