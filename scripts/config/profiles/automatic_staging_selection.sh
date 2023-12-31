#!/usr/bin/env bash

set -euo pipefail

#######################################
# Applies the staging configuration profile to the current environment.
# Arguments:
#  None
#######################################
function automatic_staging_selection() {
  # Validate the installer profile configuration if it exists.
  validate_installer_profile_configuration "${INSTALL_PROFILE}"
  apply_profile "${INSTALL_PROFILE}" "staging_config"
}
