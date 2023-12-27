#!/usr/bin/env bash

set -euo pipefail

#######################################
# description
# Arguments:
#  None
#######################################
automatic_production_selection() {
    apply_profile "prod_config"
}
