#!/usr/bin/env bash

set -euo pipefail

#######################################
# Takes a file path as an argument and backs it up if it exists and is a file
# Arguments:
#   1
#######################################
backup_existing_file() {
  [[ -f ${1} ]] && cp "${1}" "${1}.backup" && print_message "Backup created at \"${1}.backup\""
}