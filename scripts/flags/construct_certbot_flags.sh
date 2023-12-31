#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Constructs the certbot flags based on the global variables set by the user.
# Globals:
#   DRY_RUN_FLAG
#   EMAIL_FLAG
#   FORCE_RENEW_FLAG
#   HSTS_FLAG
#   LETSENCRYPT_EMAIL
#   MUST_STAPLE_FLAG
#   OCSP_STAPLING_FLAG
#   OVERWRITE_SELF_SIGNED_CERTS_FLAG
#   PRODUCTION_CERTS_FLAG
#   STRICT_PERMISSIONS_FLAG
#   UIR_FLAG
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
function construct_certbot_flags() {
  EMAIL_FLAG=$([[ ${LETSENCRYPT_EMAIL} == "skip" ]] && echo "--register-unsafely-without-email" || echo "--email ${LETSENCRYPT_EMAIL}")
  PRODUCTION_CERTS_FLAG=$([[ ${USE_PRODUCTION_SSL} == "true" ]] && echo "" || echo "--staging")
  DRY_RUN_FLAG=$([[ ${USE_DRY_RUN} == "true" ]] && echo "--dry-run" || echo "")
  FORCE_RENEW_FLAG=$([[ ${USE_FORCE_RENEW} == "true" ]] && echo "--force-renewal" || echo "")
  OVERWRITE_SELF_SIGNED_CERTS_FLAG=$([[ ${USE_OVERWRITE_SELF_SIGNED_CERTS} == "true" ]] && echo "--overwrite-cert-dirs" || echo "")
  OCSP_STAPLING_FLAG=$([[ ${USE_OCSP_STAPLING} == "true" ]] && echo "--staple-ocsp" || echo "")
  MUST_STAPLE_FLAG=$([[ ${USE_MUST_STAPLE} == "true" ]] && echo "--must-staple" || echo "")
  STRICT_PERMISSIONS_FLAG=$([[ ${USE_STRICT_PERMISSIONS} == "true" ]] && echo "--strict-permissions" || echo "")
  HSTS_FLAG=$([[ ${USE_HSTS} == "true" ]] && echo "--hsts" || echo "")
  UIR_FLAG=$([[ ${USE_UIR} == "true" ]] && echo "--uir" || echo "")
}
