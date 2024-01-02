#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

# Constants for UI
readonly WELCOME_MESSAGE="QRGen - QR Code Generation Service"
readonly THANK_YOU_MESSAGE="Task completed!"
readonly SELECT_PROMPT='Please enter your selection: '
readonly OPTIONS=("Run Setup" "Run Mock Configuration" "Uninstall" "Dump logs"
  "Update Project" "Stop Project Docker Containers"
  "Purge Current Builds - Dangerous" "Quit")
readonly INVALID_OPTION_MESSAGE="Invalid option selected."
readonly PLEASE_SELECT_OPTION_MESSAGE="Please select an option from the menu."

# Main menu function
function prompt_user() {
  while true; do
    print_messages "${WELCOME_MESSAGE}" "${PLEASE_SELECT_OPTION_MESSAGE}"
    local user_selection
    PS3=${SELECT_PROMPT}
    select user_selection in "${OPTIONS[@]}"; do
      if [[ -n ${user_selection} ]]; then
        if prompt_user_selection_switch "${user_selection}"; then
          print_messages "${THANK_YOU_MESSAGE}"
        fi
      else
        print_messages "${INVALID_OPTION_MESSAGE}" "${PLEASE_SELECT_OPTION_MESSAGE}"
      fi
      # Exit the select loop and return to the outer loop, re-displaying the menu
      break
    done
  done
}
