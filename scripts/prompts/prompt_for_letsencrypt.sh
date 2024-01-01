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
  if [[ ${USE_LETSENCRYPT} == "true" ]] || [[ ${AUTO_SETUP_CHOICE} == "true" ]]; then
    return
else
    prompt_yes_no "Would you like to use Let's Encrypt?" USE_LETSENCRYPT
    if [[ ${USE_LETSENCRYPT} == "false" ]]; then
      return
  else
      prompt_for_letsencrypt_install_type
      prompt_tls_selection
  fi
fi
}
