#!/usr/bin/env bash

set -euo pipefail

#######################################
# Prompt for auto installation.
# Arguments:
#  None
#######################################
function prompt_for_auto_install() {
  print_messages "1: Auto Install" "2: Custom Install"
  prompt_numeric "Please enter your choice (1/2): " AUTO_INSTALL
    case ${AUTO_INSTALL} in
      1) enable_auto_install ;;
      2) print_messages "Custom Installation" ;;
      *) print_messages "Invalid choice, please enter 1 or 2." ;;
  esac
}
