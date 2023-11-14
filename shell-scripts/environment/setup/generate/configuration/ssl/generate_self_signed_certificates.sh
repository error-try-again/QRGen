#!/bin/bash

#######################################
# description
# Globals:
#   CERTS_DH_DIR
#   CERTS_DIR
#   dirs
#   domain_name
# Arguments:
#  None
#######################################
generate_self_signed_certificates() {
  local certs_dir="${dirs[CERTS_DIR]}"
  local certs_dh_dir="${dirs[CERTS_DH_DIR]}"

  echo "Generating self-signed certificates for ${domain_name}..."

  local certs_path=${certs_dir}/live/${domain_name}

  # Ensure the necessary directories exist
  create_directory "${certs_path}"
  create_directory "${certs_dh_dir}"

  local dh_params_path="${certs_dh_dir}/dhparam-2048.pem"

  # Check and generate new self-signed certificates if needed
  if [[ ! -f "${certs_path}/fullchain.pem" ]] || prompt_for_regeneration "${certs_path}"; then
    # Create self-signed certificate and private key
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout "${certs_path}/privkey.pem" \
      -out "${certs_path}/fullchain.pem" \
      -subj "/CN=${domain_name}"

    echo "Self-signed certificates for ${domain_name} generated at ${certs_path}."
    openssl dhparam -out "${dh_params_path}" 2048
    echo "DH parameters generated at ${dh_params_path}."
  else
    echo "Certificates for ${domain_name} already exist at ${certs_path}."
  fi
}
