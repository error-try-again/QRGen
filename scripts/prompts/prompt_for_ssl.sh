#!/usr/bin/env bash

set -euo pipefail

#######################################
# Prompts for SSL options.
# Globals:
#   AUTO_INSTALL
#   SSL_CHOICE
# Arguments:
#  None
#######################################
function prompt_for_ssl() {
  if [[ ${USE_SSL} == "true" && ${BACKEND_SCHEME} == "https" ]]; then
    print_messages "SSL is already enabled. Skipping SSL prompt."
    return
elif   [[ ${AUTO_INSTALL} == "true" ]]; then
    print_messages "Auto setup is enabled. Skipping SSL prompt."
    return
else
    print_messages "1: Enable SSL"
    print_messages "2: Do not enable SSL"
    prompt_numeric "Please enter your choice (1/2): " SSL_CHOICE
    case ${SSL_CHOICE} in
      1) enable_ssl ;;
      2) print_messages "SSL will not be enabled." ;;
      *) print_messages "Invalid choice, please enter 1 or 2." ;;
  esac
fi
}
