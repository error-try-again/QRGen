#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Setup self signed certificate configuration parameters
# Globals:
#   NGINX_SSL_PORT
#   USE_SELF_SIGNED_CERTS
# Arguments:
#  None
#######################################
function setup_self_signed_mock_parameters() {
  NGINX_SSL_PORT="443"
  USE_SELF_SIGNED_CERTS=true
  USE_LETSENCRYPT=false
  USE_SELF_SIGNED_CERTS=true
}
