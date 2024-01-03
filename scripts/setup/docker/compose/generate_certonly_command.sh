#!/usr/bin/env bash

set -euo pipefail

#######################################
# Pulls in global variables if they are defined to generate a certonly command.
# Globals:
#   DOMAIN_NAME
#   DRY_RUN_FLAG
#   EMAIL_FLAG
#   FORCE_RENEW_FLAG
#   HSTS_FLAG
#   INTERNAL_WEBROOT_DIR
#   MUST_STAPLE_FLAG
#   NON_INTERACTIVE_FLAG
#   NO_EFF_EMAIL_FLAG
#   OCSP_STAPLING_FLAG
#   OVERWRITE_SELF_SIGNED_CERTS_FLAG
#   PRODUCTION_CERTS_FLAG
#   RSA_KEY_SIZE_FLAG
#   STRICT_PERMISSIONS_FLAG
#   SUBDOMAIN
#   TOS_FLAG
#   UIR_FLAG
# Arguments:
#  None
#######################################
function generate_certonly_command() {
  echo "certonly \
--webroot \
--webroot-path=${INTERNAL_WEBROOT_DIR} \
${EMAIL_FLAG} \
${TOS_FLAG} \
${NO_EFF_EMAIL_FLAG} \
${NON_INTERACTIVE_FLAG} \
${RSA_KEY_SIZE_FLAG} \
${FORCE_RENEW_FLAG} \
${HSTS_FLAG} \
${MUST_STAPLE_FLAG} \
${UIR_FLAG} \
${OCSP_STAPLING_FLAG} \
${STRICT_PERMISSIONS_FLAG} \
${PRODUCTION_CERTS_FLAG} \
${DRY_RUN_FLAG} \
${OVERWRITE_SELF_SIGNED_CERTS_FLAG}" \
    --domains "${DOMAIN_NAME}" \
    --domains "${SUBDOMAIN}"."${DOMAIN_NAME}"
}
