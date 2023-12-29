#!/usr/bin/env bash

set -euo pipefail

#######################################
# Ensure the jq command is installed
# Arguments:
#  None
#######################################
function check_jq_exists() {
  if ! command -v jq &>/dev/null; then
    echo "jq could not be found. Please install it to run this script."
    exit 1
  fi
}
