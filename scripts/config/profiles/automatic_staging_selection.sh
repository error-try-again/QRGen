#!/usr/bin/env bash

set -euo pipefail

#######################################
# Applies the staging configuration profile to the current environment.
# Arguments:
#  None
#######################################
function automatic_staging_selection() {
  apply_profile "${LETSENCRYPT_AUTO_PROFILE}" "staging_config"
}
