#!/usr/bin/env bash

set -euo pipefail

#######################################
# description
# Arguments:
#   1
#######################################
automatic_production_reload_selection() {
  apply_profile "${1}" "prod_reload_config"
}

#######################################
# description
# Arguments:
#   1
#######################################
automatic_staging_selection() {
  apply_profile "${1}" "staging_config"
}

#######################################
# description
# Arguments:
#   1
#######################################
automatic_production_selection() {
  apply_profile "${1}" "prod_config"
}