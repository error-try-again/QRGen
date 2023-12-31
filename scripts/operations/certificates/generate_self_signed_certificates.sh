#!/usr/bin/env bash
# bashsupport disable=BP5006
set -eo pipefail

#######################################
# Handles openssl certificate generation, and dh parameters generation.
# Looks at cert paths to determine if regeneration is needed.
# Globals:
#   CERTS_DH_DIR
#   CERTS_DIR
#   DOMAIN_NAME
# Arguments:
#  None
#######################################
function handle_self_signed_certificates() {
  local certs_path="${CERTS_DIR}/live/${DOMAIN_NAME}"
  local fullchain_path="${certs_path}/fullchain.pem"
  local privkey_path="${certs_path}/privkey.pem"
  create_directory "${certs_path}"
  create_directory "${CERTS_DH_DIR}"
  check_and_generate_certificates "${fullchain_path}" "${privkey_path}"
  handle_dh_param_generation "${CERTS_DH_DIR}/dhparam.pem"
}

#######################################
# Checks if certificates exist, re-generate if needed.
# Globals:
#   DOMAIN_NAME
# Arguments:
#   fullchain_path
#   privkey_path
#######################################
function check_and_generate_certificates() {
  local fullchain_path="$1"
  local privkey_path="$2"

  if [[ ! -f "${fullchain_path}" ]] || [[ ! -f "${privkey_path}" ]] || [[ ${REGENERATE_SSL_CERTS} == "true" ]]; then
    generate_self_signed_certificates "${privkey_path}" "${fullchain_path}"
  elif [[ -f "${fullchain_path}" ]] && [[ -f "${privkey_path}" ]]; then
    prompt_for_certificate_regeneration
    if [[ ${REGENERATE_SSL_CERTS} == "true" ]]; then
      generate_self_signed_certificates "${privkey_path}" "${fullchain_path}"
    fi
  else
    print_messages "Certificates for ${DOMAIN_NAME} already exist."
  fi
}

#######################################
# Generates a Diffie-Hellman (DH) key exchange parameters file with a given size.
# Globals:
#   DH_PARAM_SIZE
# Arguments:
#   DH_PARAMS_FILE
#######################################
function generate_dh_parameters() {
  local DH_PARAMS_FILE="$1"
  print_messages "Generating a Diffie-Hellman (DH) key exchange parameters file with ${DH_PARAM_SIZE} bits..."
  openssl dhparam -out "${DH_PARAMS_FILE}" "${DH_PARAM_SIZE}"
  print_messages "DH parameters generated at ${DH_PARAMS_FILE}."
}

#######################################
# Generates self-signed certificates for the given domain.
# Globals:
#   DOMAIN_NAME
# Arguments:
#   1
#   2
#######################################
function generate_self_signed_certificates() {
  local privkey_path="$1"
  local fullchain_path="$2"
  print_messages "Generating self-signed certificates for ${DOMAIN_NAME}..."
  openssl req -x509 -nodes -days 365 -newkey rsa:"${RSA_KEY_SIZE}" \
    -keyout "${privkey_path}" \
    -out "${fullchain_path}" \
    -subj "/CN=${DOMAIN_NAME}"
  if [[ ! -f "${fullchain_path}" ]] || [[ ! -f "${privkey_path}" ]]; then
    print_messages "Something went wrong while generating the certificates. Please try again."
    exit 1
  else
    print_messages "Certificates generated at ${fullchain_path} and ${privkey_path}."
  fi
}

#######################################
# Logic to handle when DH parameters need to be generated.
# Globals:
#   DH_PARAM_SIZE
#   REGENERATE_SSL_CERTS
# Arguments:
#   1
#######################################
function handle_dh_param_generation() {
  local DH_PARAMS_FILE="$1"
  # If the DH parameters file doesn't exist, or if the user wants to regenerate them, generate them.
  if [[ ! -f "${DH_PARAMS_FILE}" ]] || [[ ${REGENERATE_DH_PARAMS} == "true" ]]; then
    prompt_for_dhparam_strength
    generate_dh_parameters "${DH_PARAMS_FILE}"
  elif [[ -f "${DH_PARAMS_FILE}" ]]; then
    prompt_for_dh_param_regeneration
    if [[ ${REGENERATE_DH_PARAMS} == "true" ]]; then
      prompt_for_dhparam_strength
      generate_dh_parameters "${DH_PARAMS_FILE}"
    fi
  else
    print_messages "DH parameters already exist."
  fi
}

#######################################
# Prompts the user to select whether they want to regenerate the DH Parameters.
# Globals:
#   REGENERATE_SSL_CERTS
# Arguments:
#   None
# Returns:
#   0 if need to regenerate
#   1 otherwise
#######################################
function prompt_for_dh_param_regeneration() {
  # If auto install is enabled, don't prompt the user.
  if [[ ${AUTO_INSTALL} == "true" ]]; then
    return
  fi
  read -rp "Do you want to regenerate the DH parameters? [y/N]: " response
  if [[ "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    REGENERATE_DH_PARAMS="true"
  else
    REGENERATE_DH_PARAMS="false"
    print_messages "Skipping DH parameters generation."
  fi
}

#######################################
# Prompts the user to select whether they want to regenerate the self-signed certificates.
# Arguments:
#  None
# Returns:
#   0 ...
#   1 ...
#######################################
function prompt_for_certificate_regeneration() {
  # If auto install is enabled, don't prompt the user.
  if [[ ${AUTO_INSTALL} == "true" ]]; then
    return
  fi
  read -rp "Do you want to regenerate the self-signed certificates? [y/N]: " response
  if [[ "${response}" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    REGENERATE_SSL_CERTS="true"
else
    REGENERATE_SSL_CERTS="false"
    print_messages "Skipping self-signed certificates generation."
fi
}

#######################################
# Prompts the user to select which DH Param strength they want to use.
# Globals:
#   DH_PARAM_CHOICE
#   DH_PARAM_SIZE
# Arguments:
#  None
#######################################
function prompt_for_dhparam_strength() {
  if [[ ${DH_PARAM_SIZE} -eq 2048 || ${DH_PARAM_SIZE} -eq 4096 ]]; then
    print_messages "DH Parameters size is already set to ${DH_PARAM_SIZE}. Skipping prompt."
    return
  fi
  print_messages "1: Use 2048-bit DH parameters (Faster)"
  print_messages "2: Use 4096-bit DH parameters (More secure)"
  prompt_numeric "Please enter your choice (1/2): " DH_PARAM_CHOICE
  case ${DH_PARAM_CHOICE} in
    1) DH_PARAM_SIZE=2048 ;;
    2) DH_PARAM_SIZE=4096 ;;
    *)
      print_messages "Invalid choice. Please enter 1 or 2."
      prompt_for_dhparam_strength
      ;;
  esac
}
