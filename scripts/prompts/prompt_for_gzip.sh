#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# description
# Arguments:
#  None
#######################################
function prompt_for_gzip() {
  if [[ $USE_GZIP == "true" ]]; then
    return
  fi
  prompt_yes_no "Would you like to enable gzip?" USE_GZIP
}
