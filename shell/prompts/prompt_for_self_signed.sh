#!/usr/bin/env bash

set -euo pipefail

# ######################################
# description
# Globals:
#   USE_SELF_SIGNED_CERTS
# Arguments:
#  None
#######################################
prompt_for_self_signed_certificates() {
  if [[ $USE_SELF_SIGNED_CERTS == "true" ]]; then
    return
  fi
  yes_no_prompt "Would you like to enable self-signed certificates?" USE_SELF_SIGNED_CERTS
}
