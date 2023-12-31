#!/usr/bin/env bash

set -euo pipefail

#######################################
# Creates a directory if it doesn't exist.
# Arguments:
#   1
#######################################
function create_directory() {
  local directory="$1"
  if [[ ! -d ${directory}   ]]; then
    mkdir -p "${directory}"
    print_messages "${directory} created."
  else
    print_messages "${directory} already exists."
  fi
}
