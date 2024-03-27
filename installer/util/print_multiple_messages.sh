#!/usr/bin/env bash

set -euo pipefail

#######################################
# Print message to the console with a prefix and suffix message if provided and not empty
# Arguments:
#  None
#######################################
print_multiple_messages() {
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

    # Call the print_message with the two messages
    echo "---------------------------------------"
    print_message "${primary_msg}" "${secondary_msg}"
    echo "---------------------------------------"
  done
}