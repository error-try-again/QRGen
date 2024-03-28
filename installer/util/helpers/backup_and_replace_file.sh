#!/usr/bin/env bash

set -euo pipefail

#######################################
# Replace the original file with the modified version and backup the original file.
# Arguments:
#   1
#   2
#######################################
backup_and_replace_file() {
  local original_file=$1
  local modified_file=$2

  # Backup the original file
  cp -rf "${original_file}" "${original_file}.backup"

  # Replace the original file with the modified version
  mv "${modified_file}" "${original_file}"
  print_multiple_messages "File updated and original version backed up."
}