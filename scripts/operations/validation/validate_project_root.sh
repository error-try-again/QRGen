#!/usr/bin/env bash

set -euo pipefail

#######################################
# Validates that the PROJECT_ROOT_DIR is set.
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
validate_project_root_dir() {
    if [ -z "$PROJECT_ROOT_DIR" ]; then
        echo "Error: PROJECT_ROOT_DIR is not set."
        return 1
  fi
}
