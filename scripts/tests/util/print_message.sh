#!/usr/bin/env bash

set -euo pipefail

#######################################
# Prints a basic message to stdout
# Accepts an optional secondary message
# Arguments:
#  message
#  secondary_message
# Returns:
#  None
#######################################
function print_message() {
  local message
  local secondary_message
  local report_message

  message="${1}"
  secondary_message="${2:-""}"

  report_message="| $(report_timestamp) | ${message}"

  if [[ -n ${secondary_message:-} ]]; then
    report_message+=$'\n'"| $(report_timestamp) | ${secondary_message}"
  fi

  echo "${report_message}"
}
