#!/usr/bin/env bash

#######################################
# Print a separated message to stdout with an optional secondary message.
# Arguments:
#   1
#######################################
function print_multi_separated_message() {
  local message
  local secondary_message

  message="${1:-""}"
  secondary_message="${2:-""}"

  print_separator
  print_message "${message}" "${secondary_message}"
  print_separator
}
