#!/usr/bin/env bash

set -euo pipefail

#######################################
# Prompts for SSL options.
# Globals:
#   AUTO_SETUP_CHOICE
#   SSL_CHOICE
# Arguments:
#  None
#######################################
function prompt_for_ssl() {
  echo "1: Enable SSL"
  echo "2: Do not enable SSL"
  prompt_numeric "Please enter your choice (1/2): " SSL_CHOICE
  case ${SSL_CHOICE} in
    1) enable_ssl ;;
    2) echo "SSL will not be enabled." ;;
    *) echo "Invalid choice, please enter 1 or 2." ;;
  esac
}
