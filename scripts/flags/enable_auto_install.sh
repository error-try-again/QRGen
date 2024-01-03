#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Enables Auto Install
# Globals:
#   AUTO_INSTALL
# Arguments:
#   None
#######################################
function enable_auto_install() {
  AUTO_INSTALL=true
}
