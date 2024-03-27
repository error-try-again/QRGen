#!/usr/bin/env bash

set -euo pipefail

#######################################
# description
# Globals:
#   use_letsencrypt
#   use_self_signed_certs
# Arguments:
#  None
#######################################
handle_certs() {
  if [[ ${use_letsencrypt:-false} == "true" || ${use_self_signed_certs:-false} == "true" ]]; then
    generate_self_signed_certificates_for_services
  fi
}

#######################################
# description
# Globals:
#   use_custom_domain
# Arguments:
#  None
#######################################
handle_ssl_types() {
  if [[ ${use_custom_domain:-false} == "true" ]]; then
    prompt_for_ssl
    prompt_for_letsencrypt
    construct_certbot_flags
  else
    prompt_for_self_signed_certificates
  fi
}

#######################################
# description
# Globals:
#   certs_dir
#   regenerate_ssl_certificates
#   rsa_key_size
#   service_to_standard_config_map
# Arguments:
#  None
#######################################
generate_self_signed_certificates_for_services() {
  generate_dh_params
  local service_name service_config domain
  local regenerate_needed=false

  # First, check if any certificate needs regeneration or creation
  for service_name in "${!service_to_standard_config_map[@]}"; do
    service_config="${service_to_standard_config_map[$service_name]}"
    echo "$service_config" | jq -r '.domains[]' | while read -r domain; do
      local certs_path="${certs_dir}/${domain}"
      local fullchain_path="${certs_path}/fullchain.pem"
      local privkey_path="${certs_path}/privkey.pem"

      if [[ ${regenerate_ssl_certificates} == "true" ]] || [[ ! -f ${fullchain_path} ]] || [[ ! -f ${privkey_path} ]]; then
        regenerate_needed=true
        break 2  # Break out of both loops
      fi
    done
    if [[ $regenerate_needed == true ]]; then
      break  # Break out of the outer loop if regeneration is needed
    fi
  done

  # Then, only proceed if regeneration is needed
  if [[ $regenerate_needed == true ]]; then
    for service_name in "${!service_to_standard_config_map[@]}"; do
      service_config="${service_to_standard_config_map[$service_name]}"
      echo "$service_config" | jq -r '.domains[]' | while read -r domain; do
        generate_certificate_if_needed "${domain}" "${certs_dir}" "${rsa_key_size}" "${regenerate_ssl_certificates}"
      done
    done
  else
    echo "All certificates are up to date; skipping regeneration."
  fi
}

#######################################
# description
# Arguments:
#   1
#   2
#   3
#   4
# Returns:
#   1 ...
#   2 ...
#######################################
generate_certificate_if_needed() {
  local domain="$1" certs_dir="$2" rsa_key_size="$3" regenerate="$4"
  local certs_path="${certs_dir}/${domain}"
  local fullchain_path="${certs_path}/fullchain.pem"
  local privkey_path="${certs_path}/privkey.pem"

  mkdir -p "${certs_path}"

  if [[ ${regenerate} == "true" ]] || [[ ! -f ${fullchain_path} ]] || [[ ! -f ${privkey_path} ]]; then
    echo "Generating self-signed certificates for ${domain}..."
    if openssl req -x509 -nodes -days 365 -newkey rsa:"${rsa_key_size}" -keyout "${privkey_path}" -out "${fullchain_path}" -subj "/CN=${domain}"; then
      echo "Certificates generated at ${fullchain_path} and ${privkey_path}."
    else
      echo "Error generating certificates for ${domain}."
      return 1
    fi
  else
    echo "Certificates already exist at ${fullchain_path} and ${privkey_path}, skipping."
    return 2
  fi
}
#######################################
# description
# Globals:
#   certificates_diffie_hellman_directory
#   diffie_hellman_parameter_bit_size
#   regenerate_diffie_hellman_parameters
# Arguments:
#  None
#######################################
generate_dh_params() {
  local dh_param_path="${certificates_diffie_hellman_directory}/dhparam.pem"
  mkdir -p "${certificates_diffie_hellman_directory}"

  if [[ ${regenerate_diffie_hellman_parameters:-false} == "true" ]] || [[ ! -f ${dh_param_path} ]]; then
    echo "Generating Diffie-Hellman parameters..."
    openssl dhparam -out "${dh_param_path}" "${diffie_hellman_parameter_bit_size}"
  else
    echo "DH parameters already exist at ${dh_param_path}."
  fi
}

#######################################
# description
# Globals:
#   auto_install_flag
#   regenerate_ssl_certificates
# Arguments:
#  None
#######################################
prompt_for_certificate_regeneration() {
  regenerate_ssl_certificates="false"
  if [[ ${auto_install_flag:-false} != "true" ]]; then
    read -rp "Do you want to regenerate the self-signed certificates? [y/N]: " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
      regenerate_ssl_certificates="true"
    else
      echo "Skipping self-signed certificates generation."
    fi
  fi
}

#######################################
# description
# Globals:
#   diffie_hellman_parameter_bit_size
#   diffie_hellman_parameter_choice
# Arguments:
#  None
# Returns:
#   <unknown> ...
#######################################
prompt_for_dhparam_strength() {
  if [[ ${diffie_hellman_parameter_bit_size} -eq 2048 || ${diffie_hellman_parameter_bit_size} -eq 4096 ]]; then
    print_multiple_messages "DH Parameters size is already set to ${diffie_hellman_parameter_bit_size}. Skipping prompt."
    return
  fi
  print_multiple_messages "1: Use 2048-bit DH parameters (Faster)"
  print_multiple_messages "2: Use 4096-bit DH parameters (More secure)"
  prompt_numeric "Please enter your choice (1/2): " diffie_hellman_parameter_choice
  case ${diffie_hellman_parameter_choice} in
    1) diffie_hellman_parameter_bit_size=2048 ;;
    2) diffie_hellman_parameter_bit_size=4096 ;;
    *)
      print_multiple_messages "Invalid choice. Please enter 1 or 2."
      prompt_for_dhparam_strength
      ;;
  esac
}