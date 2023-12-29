#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Setup lets encrypt configuration parameters
# Globals:
#   USE_GZIP
#   USE_LETSENCRYPT
#   DRY_RUN_FLAG
#   EMAIL_FLAG
#   FORCE_RENEW_FLAG
#   HSTS_FLAG
#   MUST_STAPLE_FLAG
#   OSCP_STAPLING_FLAG
#   OVERWRITE_SELF_SIGNED_CERTS_FLAG
#   PRODUCTION_CERTS_FLAG
#   STRICT_PERMISSIONS_FLAG
#   UIR_FLAG
# Arguments:
#  None
#######################################
function setup_letsencrypt_mock_parameters() {
  USE_LETSENCRYPT=true
  EMAIL_FLAG="--email example@example.com"
  PRODUCTION_CERTS_FLAG="--production-certs"
  DRY_RUN_FLAG="--dry-run"
  FORCE_RENEW_FLAG="--force-renew"
  OVERWRITE_SELF_SIGNED_CERTS_FLAG="--overwrite-cert-dirs"
  OCSP_STAPLING_FLAG="--staple-ocsp"
  MUST_STAPLE_FLAG="--must-staple"
  STRICT_PERMISSIONS_FLAG="--strict-permissions"
  HSTS_FLAG="--hsts"
  UIR_FLAG="--uir"
  USE_GZIP=true
}
