#!/usr/bin/env bash

set -euo pipefail

#######################################
# Applies the staging configuration profile to the current environment.
# Arguments:
#  None
#######################################
function automatic_staging_selection() {
  apply_profile "${INSTALL_PROFILE}" "staging_config"
}
