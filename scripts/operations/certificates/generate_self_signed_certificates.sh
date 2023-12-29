#!/usr/bin/env bash

set -euo pipefail

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

  local certs_path=${CERTS_DIR}/live/${DOMAIN_NAME}

  # Ensure the necessary directories exist
  create_directory "${certs_path}"
  create_directory "${CERTS_DH_DIR}"

  local dh_params_path="${CERTS_DH_DIR}/dhparam.pem"

  if [[ ! -f "${dh_params_path}" ]]; then
    echo "DH parameters file not found at ${dh_params_path}."
fi

  # Check and generate new self-signed certificates if needed
  if [[ ! -f "${certs_path}/fullchain.pem" ]] || prompt_for_dhparam_regeneration "${certs_path}"; then
    # Create self-signed certificate and private key
    openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
      -keyout "${certs_path}/privkey.pem" \
      -out "${certs_path}/fullchain.pem" \
      -subj "/CN=${DOMAIN_NAME}"

    echo "Self-signed certificates for ${DOMAIN_NAME} generated at ${certs_path}."

    # Generate DH parameters
    prompt_for_dhparam_strength
    echo "Generate a Diffie-Hellman (DH) key exchange parameters file with ${DH_PARAM_SIZE} bits..."
    openssl dhparam -out "${dh_params_path}" "${DH_PARAM_SIZE}"
    echo "DH parameters generated at ${dh_params_path}."
  else
    echo "Certificates for ${DOMAIN_NAME} already exist at ${certs_path}."
  fi
}
