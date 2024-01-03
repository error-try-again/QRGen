#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Assert that NGINX config has defined port(s)
# Arguments:
#   $1 - NGINX configuration file
#######################################
function assert_nginx_has_port() {
  local file=$1

  # Check for port definition in NGINX config
  if ! grep -qE 'listen[[:space:]]+[0-9]+' "${file}"; then
    log_mock_error "missing_port"
  fi
}
