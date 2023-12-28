#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail


#######################################
# Custom prompt mechanism for the user to select from - allows for more flexibility than the automatic SSL setup.
# Globals:
#   USE_LETSENCRYPT
# Arguments:
#  None
#######################################
function prompt_for_custom_certbot_install() {
  USE_LETSENCRYPT=true
  prompt_yes_no "Would you like to build with Certbot? (Recommended)" BUILD_CERTBOT_IMAGE
  handle_certbot_image_selection
}

#######################################
# Checks if the certbot image is selected and handles it
# Globals:
#   BUILD_CERTBOT_IMAGE
# Arguments:
#  None
#######################################
function handle_certbot_image_selection() {
  if [[ $BUILD_CERTBOT_IMAGE ]]; then
    prompt_for_letsencrypt
  else
    prompt_tls_selection
  fi
}
