#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# description
# Arguments:
#  None
#######################################
disable_docker_build_caching_prompt() {
  if [[ ${DISABLE_DOCKER_CACHING} == "true" ]]; then
    return
  fi
  yes_no_prompt "Would you like to disable Docker build caching for this run?" DISABLE_DOCKER_CACHING
}
