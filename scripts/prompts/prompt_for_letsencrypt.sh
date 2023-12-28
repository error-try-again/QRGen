#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Prompts the user for the Let's Encrypt email and other Let's Encrypt related settings.
# Globals:
#   LETSENCRYPT_EMAIL
#   USE_AUTO_RENEW_SSL
#   USE_DRY_RUN
#   USE_FORCE_RENEW
#   USE_HSTS
#   USE_MUST_STAPLE
#   USE_OCSP_STAPLING
#   USE_OVERWRITE_SELF_SIGNED_CERTS
#   USE_PRODUCTION_SSL
#   USE_STRICT_PERMISSIONS
#   USE_UIR
# Arguments:
#  None
#######################################
function prompt_for_letsencrypt() {
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
  prompt_tls_selection
}
