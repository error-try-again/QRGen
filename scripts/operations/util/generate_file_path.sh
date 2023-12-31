#!/usr/bin/env bash

set -euo pipefail

#######################################
# description
# Arguments:
#   1
# Returns:
#   1 ...
#######################################
function generate_file_paths() {
  if [[ $# -eq 0 ]]; then
    print_messages "No arguments supplied"
    return 1
  fi

  local file_name="${1}"
  if [[ ! -f ${file_name}   ]]; then
    print_messages "File not found: ${file_name} | generating..."
    mkdir -p "$(dirname "${file_name}")"
    touch "${file_name}"
  fi
}
