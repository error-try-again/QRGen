#!/usr/bin/env bash

set -euo pipefail

#######################################
# Validate that a file exists
# Arguments:
#   1
#######################################
validate_file_exists() {
  local file
  file="${1}"

  if [[ ! -f ${file}   ]]; then
    print_multiple_messages "Configuration file ${file} does not exist." "Please create the file and try again."
    exit 1
  else
    print_multiple_messages "Configuration file ${file} exists." "Proceeding with the installation."
    return 0
  fi
}