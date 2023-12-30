#!/usr/bin/env bash

set -euo pipefail

#######################################
# Backs up the original file and replaces it with the modified version
# Globals:
#   None
# Arguments:
#   1 - Original file
#   2 - Modified file
#######################################
function backup_and_replace_file() {
  local original_file=$1
  local modified_file=$2

  # Backup the original file
  cp -rf "${original_file}" "${original_file}.backup"

  # Replace the original file with the modified version
  mv "${modified_file}" "${original_file}"
  echo "File updated and original version backed up."
}
