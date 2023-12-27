#!/usr/bin/env bash

set -euo pipefail

#######################################
# description
# Arguments:
#  None
#######################################
automatic_staging_selection() {
    apply_profile "staging_config"
}
