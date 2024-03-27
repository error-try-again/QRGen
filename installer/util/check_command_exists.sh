#!/usr/bin/env bash

set -euo pipefail

#######################################
# Check if a command exists and exit if it does not. Print a message if it does not exist.
# Arguments:
#   1
#   2
#######################################
check_command_exists() {
  local command="$1"
  local message="$2"

  if ! command -v "${command}" &> /dev/null; then
    print_multiple_messages "${message}"
    exit 1
  fi
}