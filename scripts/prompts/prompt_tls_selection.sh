#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# description
# Globals:
#   USE_TLS12
#   USE_TLS13
# Arguments:
#  None
#######################################
prompt_tls_selection() {
  prompt_yes_no "Would you like to enable TLSv1.3? (Recommended): " USE_TLS13
  prompt_yes_no "Would you like to enable TLSv1.2?" USE_TLS12
}
