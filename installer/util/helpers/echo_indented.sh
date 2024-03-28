#!/usr/bin/env bash

set -euo pipefail

#######################################
# Output a message with indentation based on the level provided as the first argument. e.g. echo_indented 2 "Hello"
# Arguments:
#   1
#   2
#######################################
echo_indented() {
  local level=$1
  local message=$2
  printf '%*s%s\n' "${level}" '' "${message}"
}