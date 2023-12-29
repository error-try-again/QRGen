#!/usr/bin/env bash

set -eo pipefail

#######################################
# Handles openssl certificate generation, and dh parameters generation.
# Looks at cert paths to determine if regeneration is needed.
# Globals:
#   CERTS_DH_DIR
#   CERTS_DIR
#   dirs
#   DOMAIN_NAME
# Arguments:
#  None
#######################################
function generate_self_signed_certificates() {
  echo "Generating self-signed certificates for ${DOMAIN_NAME}..."

  export certs_path=${CERTS_DIR}/live/${DOMAIN_NAME}
  local fullchain_path="${certs_path}/fullchain.pem"
  local privkey_path="${certs_path}/privkey.pem"

  local dh_params_path="${CERTS_DH_DIR}/dhparam.pem"

  # Ensure the necessary directories exist
  create_directory "${certs_path}"
  create_directory "${CERTS_DH_DIR}"

  check_and_generate_certificates "${fullchain_path}" "${privkey_path}"
  generate_dh_parameters "${dh_params_path}"
}

#######################################
# description
# Globals:
#   DOMAIN_NAME
#   certs_path
# Arguments:
#   1K
#   2
#######################################
function check_and_generate_certificates() {
  local fullchain_path=$1
  local privkey_path=$2

  if [[ ! -f "${fullchain_path}" ]] || prompt_for_dhparam_regeneration "${certs_path}"; then
    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
      -keyout "${privkey_path}" \
      -out "${fullchain_path}" \
      -subj "/CN=${DOMAIN_NAME}"
    echo "Self-signed certificates for ${DOMAIN_NAME} generated at ${certs_path}."
  else
    echo "Certificates for ${DOMAIN_NAME} already exist at ${certs_path}."
  fi
}

#######################################
# description
# Globals:
#   DH_PARAM_SIZE
# Arguments:
#   1
#######################################
function generate_dh_parameters() {
  local dh_params_path=$1

  if [[ ! -f "${dh_params_path}" ]]; then
    echo "DH parameters file not found at ${dh_params_path}. Generating new DH parameters."

    prompt_for_dhparam_strength
    echo "Generate a Diffie-Hellman (DH) key exchange parameters file with ${DH_PARAM_SIZE} bits..."  openssl dhparam -out "${dh_params_path}" "${DH_PARAM_SIZE}"
    echo "DH parameters generated at ${dh_params_path}."
  fi
}
