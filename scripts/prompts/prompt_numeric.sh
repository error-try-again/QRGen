#!/usr/bin/env bash

set -euo pipefail

#######################################
# A numeric prompt that takes the prompt message and the variable name to store the result in.
# Outputs the result to stdout.
# Arguments:
#   1
#   2
#######################################
prompt_numeric() {
  local prompt_message=$1
  local var_name=$2
  local input
  read -rp "${prompt_message}" input
  while ! [[ ${input} =~ ^[0-9]+$ ]]; do
    echo "Please enter a valid number."
    read -rp "${prompt_message}" input
  done
  eval "${var_name}"="'${input}'"
}
