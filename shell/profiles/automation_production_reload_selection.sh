#!/usr/bin/env bash

set -euo pipefail

#######################################
# description
# Arguments:
#  None
#######################################
automatic_production_reload_selection() {
    apply_profile "prod_reload_config"
}
