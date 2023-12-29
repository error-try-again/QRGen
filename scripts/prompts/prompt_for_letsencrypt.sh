#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Prompts to use Let's Encrypt. If yes, prompts for certbot flag settings & TLS selection.
# If no, returns to proceed with self-signed certificates.
# Globals:
#   USE_LETSENCRYPT
#   LETSENCRYPT_EMAIL
#   USE_PRODUCTION_SSL
#   USE_DRY_RUN
#   USE_FORCE_RENEW
#   USE_AUTO_RENEW_SSL
#   USE_HSTS
#   USE_OCSP_STAPLING
#   USE_MUST_STAPLE
#   USE_UIR
#   USE_STRICT_PERMISSIONS
#   USE_OVERWRITE_SELF_SIGNED_CERTS
# Arguments:
#  None
# Returns:
#   <unknown> ...
#######################################
function prompt_for_letsencrypt() {
  prompt_yes_no "Would you like to use Let's Encrypt?" USE_LETSENCRYPT
  if [[ "${USE_LETSENCRYPT}" == "false" ]]; then
    return
  else
    prompt_for_letsencrypt_install_type
    certbot_prompts
    prompt_tls_selection
  fi
}

#######################################
# Prompts the user for certbot flag settings.
# Arguments:
#  None
#######################################
function certbot_prompts() {
  prompt_and_validate_input "Please enter your Let's Encrypt email or type 'skip' to skip: " "Error: Email address cannot be empty." LETSENCRYPT_EMAIL
  prompt_yes_no "Would you like to use a production SSL certificate?" USE_PRODUCTION_SSL
  prompt_yes_no "Would you like to use a dry run?" USE_DRY_RUN
  prompt_yes_no "Would you like to force current certificate renewal?" USE_FORCE_RENEW
  prompt_yes_no "Would you like to automatically renew your SSL certificate?" USE_AUTO_RENEW_SSL
  prompt_yes_no "Would you like to enable HSTS (Recommended)?" USE_HSTS
  prompt_yes_no "Would you like to enable OCSP Stapling (Recommended)?" USE_OCSP_STAPLING
  prompt_yes_no "Would you like to enable Must Staple (Not Recommended)?" USE_MUST_STAPLE
  prompt_yes_no "Would you like to enable UIR (Unique Identifier for Revocation)?" USE_UIR
  prompt_yes_no "Would you like to enable Strict Permissions (Not Recommended)?" USE_STRICT_PERMISSIONS
  prompt_yes_no "Would you like to overwrite existing certificates?" USE_OVERWRITE_SELF_SIGNED_CERTS
  prompt_yes_no "Would you like to build with Certbot? (Highly Recommended)" BUILD_CERTBOT_IMAGE
}
