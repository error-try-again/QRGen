#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Assert that Docker Compose config has defined port(s)
# Arguments:
#   $1 - Docker Compose configuration file
#######################################
function assert_compose_has_port() {
  local file=$1

  # A check for port definition in Docker Compose config
  if ! grep -q 'ports:' "${file}"; then
    log_mock_error "missing_port"
  fi
}
