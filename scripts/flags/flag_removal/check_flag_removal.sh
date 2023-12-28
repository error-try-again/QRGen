#!/usr/bin/env bash

set -euo pipefail

#######################################
# Checks if the specified flag is removed from the file
# Globals:
#   None
# Arguments:
#   1 - File to check
#   2 - Flag to check for
#######################################
function check_flag_removal() {
  local file=$1
  local flag=$2

  if grep --quiet -- "$flag" "$file"; then
    echo "$flag removal failed."
    rm "$file"
    exit 1
  else
    echo "$flag removed successfully."
  fi
}
