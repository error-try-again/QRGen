#!/usr/bin/env bash

set -euo pipefail

#######################################
# Prompts the user to select whether they want to use a custom domain and prompts for the relevant information.
# Globals:
#   USE_CUSTOM_DOMAIN
# Arguments:
#  None
#######################################
prompt_for_domain_and_letsencrypt() {
  prompt_for_domain_details
  if [[ $USE_CUSTOM_DOMAIN ]]; then
    prompt_for_ssl
    construct_certbot_flags
  else
    prompt_for_self_signed_certificates
  fi
}
