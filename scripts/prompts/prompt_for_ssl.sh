#!/usr/bin/env bash

set -euo pipefail

#######################################
# Prompts for SSL options.
# Globals:
#   AUTO_SETUP_CHOICE
#   SSL_CHOICE
# Arguments:
#  None
#######################################
prompt_for_ssl() {
  echo "1: Use Let's Encrypt SSL"
  echo "2: Use self-signed SSL certificates"
  echo "3: Do not enable SSL"
  prompt_numeric "Please enter your choice (1/2/3): " SSL_CHOICE
  case $SSL_CHOICE in
    1) prompt_for_letsencrypt_options ;;
    2) enable_ssl ;;
    3) echo "SSL will not be enabled." ;;
    *)
       echo "Invalid choice, please enter 1, 2, or 3."
                                                       ;;
  esac
}
