#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# description
# Arguments:
#  None
#######################################
prompt_for_gzip() {
  if [[ $USE_GZIP == "true" ]]; then
    return
  fi
  yes_no_prompt "Would you like to enable gzip?" USE_GZIP
}
