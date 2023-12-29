#!/usr/bin/env bash

set -euo pipefail

#######################################
# Handle the concatenation of port or volume mappings into a comma-separated string.
# Arguments:
#  None
#######################################
function join_with_commas() {
  local mappings=("${@:2}") # Assigns all arguments except the first one to 'mappings' array.
  local result=""           # Initializes the result string.
  local first=true          # Flag to check if the current mapping is the first one to avoid leading comma.
  local mapping             # Variable to hold the current mapping in the loop.

  # Loop through each mapping.
  for mapping in "${mappings[@]}"; do
    if [[ "${first}" = true ]]; then # Check if this is the first mapping.
      first=false                    # Set first to false after the first iteration.
    else
      result+="," # Append a comma before the next mapping if it's not the first one.
    fi
    result+="${mapping}" # Append the current mapping to the result string.
  done
  echo "${result}" # Output the concatenated result.
}
