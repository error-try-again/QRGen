#!/usr/bin/env bash

set -euo pipefail

#######################################
# Prompt the user for domain and SSL certificate details when setting up the server.
# Globals:
#   USE_CUSTOM_DOMAIN
# Arguments:
#  None
#######################################
function prompt_for_domain_and_letsencrypt() {
  prompt_for_domain_details
  decide_on_ssl_or_self_signed
}

#######################################
# If a custom domain is in use, it prompts for SSL and LetsEncrypt details along with the corresponding Certbot flags.
# If a custom domain is not in use, it will prompt for self-signed certificates.
# Globals:
#   USE_CUSTOM_DOMAIN
# Arguments:
#  None
#######################################
function decide_on_ssl_or_self_signed() {
  if [[ -n ${USE_CUSTOM_DOMAIN} ]] && [[ ${USE_CUSTOM_DOMAIN} == "true" ]]; then
    prompt_for_ssl
    prompt_for_letsencrypt
    construct_certbot_flags
else
    prompt_for_self_signed_certificates
fi
}
