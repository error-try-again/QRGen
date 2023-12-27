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
user_prompt() {
  echo "Welcome to the QR Code Generator setup script!"
  local user_selection
  PS3='Select: '
  select user_selection in "Run Setup" "Run Mock Configuration" "Uninstall" "Dump logs" "Update Project" "Stop Project Docker Containers" "Prune All Docker Builds - Dangerous" "Quit"; do
    handle_user_selection "$user_selection"
    (($? == 0)) && break
  done
  echo "Thanks for using the QR Code Generator setup script!"
}
