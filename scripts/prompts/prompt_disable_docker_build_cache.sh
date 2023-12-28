#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# description
# Arguments:
#  None
#######################################
prompt_disable_docker_build_cache() {
  if [[ ${DISABLE_DOCKER_CACHING} == "true" ]]; then
    return
  fi
  prompt_yes_no "Would you like to disable Docker build caching for this run?" DISABLE_DOCKER_CACHING
}
