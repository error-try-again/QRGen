#!/usr/bin/env bash

set -euo pipefail

############################################
# Prompts the user for input and evaluate the result - mainly used for handling email addresses input.
# Arguments:
#   prompt_message: Message to display for prompting user input
#   error_message: Message to display when the input is not valid
#   result_var: Variable to hold the user input result
############################################
function prompt_and_validate_input() {
  local prompt_message="$1"
  local error_message="$2"
  local result_var="$3"
  local input_value
  while true; do
    read -rp "${prompt_message}" input_value
    if [[ -n ${input_value} ]]; then
      break
  else
      print_messages "${error_message}"
  fi
done
}
