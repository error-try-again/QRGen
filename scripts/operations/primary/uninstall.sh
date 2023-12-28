#!/usr/bin/env bash

set -euo pipefail

#######################################
# Shuts down any running Docker containers associated with the project and deletes the entire project directory.
# Arguments:
#  None
#######################################
function uninstall() {
  test_docker_env
  echo "Cleaning up..."
  purge_builds

  # Directly delete the project root directory
  if [[ -d $PROJECT_ROOT_DIR ]]; then
    echo "Deleting Project directory $PROJECT_ROOT_DIR..."
    rm -rf "$PROJECT_ROOT_DIR"
    echo "Project directory $PROJECT_ROOT_DIR deleted."
  fi

  echo "Uninstallation complete."
}
