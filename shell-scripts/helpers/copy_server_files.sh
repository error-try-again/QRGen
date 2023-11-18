#!/bin/bash

copy_server_files() {
  echo "Copying server files..."
  copy_frontend_files
  copy_backend_files
}

copy_backend_files() {
  echo "Copying backend files..."
  cp -r "server" "$BACKEND_DIR"
  cp "tsconfig.json" "$BACKEND_DIR"
  cp ".env" "$BACKEND_DIR"
  backend_files="backend/*"
}

copy_frontend_files() {
  ls "$PROJECT_ROOT_DIR"
  echo "Copying frontend files..."
  cp -r "src" "$FRONTEND_DIR"
  cp -r "public" "$FRONTEND_DIR"
  cp "tsconfig.json" "$FRONTEND_DIR"
  cp "index.html" "$FRONTEND_DIR"
}
