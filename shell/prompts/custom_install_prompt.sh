#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Custom prompt mechanism for the user to select from - allows for more flexibility than the automatic SSL setup.
# Arguments:
#  None
#######################################
custom_install_prompt() {
  enable_letsencrypt
  yes_no_prompt "Would you like to build with Certbot? (Recommended)" BUILD_CERTBOT_IMAGE
  handle_certbot_image_selection
}
