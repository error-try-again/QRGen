#!/usr/bin/env bash

#######################################
# Print a message to stdout & optional secondary messages
# Accepts multiple messages beyond the first as secondary messages.
# Arguments:
#   @: All arguments passed to the function
#######################################
function print_messages() {
  # Loop over the arguments two at a time
  while [[ $# -gt 0 ]]; do
    # Take first argument as the primary message
    local primary_msg="${1:-""}"
    shift # move to next argument

    # Take second argument as the secondary message, if it exists
    local secondary_msg=""
    if [[ $# -gt 0 ]]; then
      secondary_msg="${1}"
      shift # move to next pair or end of arguments
    fi

    # Call the print_message function with the two messages
    print_separator
    print_message "${primary_msg}" "${secondary_msg}"
    print_separator
  done
}
