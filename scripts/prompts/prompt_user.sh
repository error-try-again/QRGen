#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail


#######################################
# Provides a basic TUI/menu for the user to select from.
# Globals:
#   PS3
# Arguments:
#  None
#######################################
function prompt_user() {
  local welcome_message="Welcome to the QR Code Generator setup script!"
  local thanks_message="Thanks for using the QR Code Generator setup script!"
  local select_prompt='Select: '
  local options=("Run Setup" "Run Mock Configuration" "Uninstall" "Dump logs"
                 "Update Project" "Stop Project Docker Containers"
                 "Prune All Docker Builds - Dangerous" "Quit")
  echo "${welcome_message}"
  local user_selection
  PS3=$select_prompt

  # Provide a menu for the user to select from and pass it to the handle_user_selection switching function.
  select user_selection in "${options[@]}"; do
    if prompt_user_selection_switch "$user_selection"; then
      break
    fi
    echo "${thanks_message}"
  done
}
