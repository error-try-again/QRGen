#!/bin/bash

#######################################
# description
# Arguments:
#  None
#######################################
copy_server_files() {
  echo "Copying server files..."
  copy_frontend_files
  copy_backend_files
}

#######################################
# description
# Globals:
#   BACKEND_DIR
#   backend_files
# Arguments:
#  None
#######################################
copy_backend_files() {
  echo "Copying backend files..."
  cp -r "server" "$BACKEND_DIR"
  cp "tsconfig.json" "$BACKEND_DIR"
  cp ".env" "$BACKEND_DIR"
  backend_files="backend/*"
}

#######################################
# description
# Globals:
#   FRONTEND_DIR
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
copy_frontend_files() {
  ls "$PROJECT_ROOT_DIR"
  echo "Copying frontend files..."
  cp -r "src" "$FRONTEND_DIR"
  cp -r "public" "$FRONTEND_DIR"
  cp "tsconfig.json" "$FRONTEND_DIR"
  cp "index.html" "$FRONTEND_DIR"
}
