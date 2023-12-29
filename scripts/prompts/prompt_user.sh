#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

# Constants for UI
readonly HEADER_LINE="----------------------------------------------"
readonly WELCOME_MESSAGE="Welcome to the QRGen setup script!"
readonly THANK_YOU_MESSAGE="Thanks for using the QR Code Generator setup script!"
readonly SELECT_PROMPT='Select: '
readonly OPTIONS=("Run Setup" "Run Mock Configuration" "Uninstall" "Dump logs"
  "Update Project" "Stop Project Docker Containers"
  "Purge Current Builds - Dangerous" "Quit")

# Print header function
function print_header() {
  echo "${HEADER_LINE}"
  echo "$1"
  echo "${HEADER_LINE}"
}

# Main menu function
function prompt_user() {
  print_header "${WELCOME_MESSAGE}"
  local user_selection
  PS3=${SELECT_PROMPT}

  select user_selection in "${OPTIONS[@]}"; do
    if [[ -n ${user_selection} ]]; then
      if prompt_user_selection_switch "${user_selection}"; then
        print_header "${THANK_YOU_MESSAGE}"
        break
      fi
    else
      echo "Invalid option. Please try again."
    fi
  done
}
