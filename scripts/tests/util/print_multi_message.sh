#!/usr/bin/env bash

#######################################
# Print a message to stdout & optional secondary message
# Arguments:
#   1
#######################################
function print_multi_message() {
  local message
  local secondary_message

  message="${1:-""}"
  secondary_message="${2:-""}"

  print_message "${message}" "${secondary_message}"
}
