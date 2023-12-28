#!/usr/bin/env bash

set -euo pipefail

# ######################################
# Prompt the user if they want to use self-signed certificates
# Globals:
#   USE_SELF_SIGNED_CERTS
# Arguments:
#  None
#######################################
function prompt_for_self_signed_certificates() {
  if [[ $USE_SELF_SIGNED_CERTS == "true" ]]; then
    return
  fi
  prompt_yes_no "Would you like to enable self-signed certificates?" USE_SELF_SIGNED_CERTS
}
