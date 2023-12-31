#!/usr/bin/env bash

set -euo pipefail

#######################################
# Applies the production configuration profile to the current environment.
# Arguments:
#  None
#######################################
function automatic_production_selection() {
  # Validate the installer profile configuration if it exists.
  validate_installer_profile_configuration "${INSTALL_PROFILE}"
  apply_profile "${INSTALL_PROFILE}" "prod_config"
}
