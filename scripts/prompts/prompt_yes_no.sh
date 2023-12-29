#!/usr/bin/env bash

set -euo pipefail

#######################################
# Prompts the user for a yes/no answer and stores the result in a variable as a boolean string.
# Arguments:
#   1
#   2
#######################################
function prompt_yes_no() {
  local prompt_message="$1"
  local result_var="$2"
  local choice
  while true; do
    read -rp "${prompt_message} [Y/n]: " choice
    case "${choice,,}" in # Convert to lowercase for easier matching
    yes | y)
      eval "${result_var}=true"
      break
      ;;
    no | n)
      eval "${result_var}=false"
      break
      ;;
    "") # Default to 'yes' if the user just presses enter
      eval "${result_var}=true"
      break
      ;;
    *) echo "Invalid input. Please enter 'yes' or 'no'." ;;
    esac
  done
}
