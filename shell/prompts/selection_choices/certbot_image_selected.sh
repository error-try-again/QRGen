#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# description
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
certbot_image_selected() {
  evaluate_valid_input_string "Please enter your Let's Encrypt email or type 'skip' to skip: " "Error: Email address cannot be empty." LETSENCRYPT_EMAIL
  yes_no_prompt "Would you like to use a production SSL certificate?" USE_PRODUCTION_SSL
  yes_no_prompt "Would you like to use a dry run?" USE_DRY_RUN
  yes_no_prompt "Would you like to force current certificate renewal?" USE_FORCE_RENEW
  yes_no_prompt "Would you like to automatically renew your SSL certificate?" USE_AUTO_RENEW_SSL
  yes_no_prompt "Would you like to enable HSTS (Recommended)?" USE_HSTS
  yes_no_prompt "Would you like to enable OCSP Stapling (Recommended)?" USE_OCSP_STAPLING
  yes_no_prompt "Would you like to enable Must Staple (Not Recommended)?" USE_MUST_STAPLE
  yes_no_prompt "Would you like to enable UIR (Unique Identifier for Revocation)?" USE_UIR
  yes_no_prompt "Would you like to enable Strict Permissions (Not Recommended)?" USE_STRICT_PERMISSIONS
  yes_no_prompt "Would you like to overwrite existing certificates?" USE_OVERWRITE_SELF_SIGNED_CERTS
  select_tls_version
}
