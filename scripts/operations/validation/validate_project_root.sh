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
function validate_project_root_dir() {
  if [[ -n ${PROJECT_ROOT_DIR} ]]; then
    return 0
  else
    print_messages "PROJECT_ROOT_DIR is not set"
    return 1
  fi
}
