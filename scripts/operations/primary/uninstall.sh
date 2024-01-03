#!/usr/bin/env bash

set -euo pipefail

#######################################
# Shuts down any running Docker containers associated with the project and deletes the entire project directory.
# Arguments:
#  None
#######################################
function uninstall() {
  test_docker_env
  print_messages "Cleaning up..."
  purge

  # Directly delete the project root directory
  if [[ -d ${PROJECT_ROOT_DIR} ]]; then
    print_messages "Deleting Project directory ${PROJECT_ROOT_DIR}..."
    rm -rf "${PROJECT_ROOT_DIR}"
    print_messages "Project directory ${PROJECT_ROOT_DIR} deleted."
  fi

  print_messages "Uninstallation complete."
}
