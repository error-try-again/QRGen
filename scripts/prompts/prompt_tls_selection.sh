#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Prompt the user to select TLS versions to enable for the servers.
# Globals:
#   USE_TLS12
#   USE_TLS13
# Arguments:
#  None
#######################################
function prompt_tls_selection() {
if [[ ${USE_TLS12} == "true" || ${USE_TLS13} == "true" ]]; then
    return
else
  prompt_yes_no "Would you like to enable TLSv1.3? (Recommended): " USE_TLS13
  prompt_yes_no "Would you like to enable TLSv1.2?" USE_TLS12
fi
}
