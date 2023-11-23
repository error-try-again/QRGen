#!/bin/bash

copy_server_files() {
  echo "Copying server files..."
  copy_frontend_files
}

copy_frontend_files() {
  echo "Copying frontend files..."
  cp -r "src" "$FRONTEND_DIR"
  cp -r "public" "$FRONTEND_DIR"
  cp "tsconfig.json" "$FRONTEND_DIR"
  cp "index.html" "$FRONTEND_DIR"
}
