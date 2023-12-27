#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Checks if the certbot image is selected and handles it
# Globals:
#   BUILD_CERTBOT_IMAGE
# Arguments:
#  None
#######################################
handle_certbot_image_selection() {
  if [[ $BUILD_CERTBOT_IMAGE ]]; then
    certbot_image_selected
  else
    select_tls_version
  fi
}
