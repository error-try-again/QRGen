#!/usr/bin/env bash

set -euo pipefail

#######################################
# description
# Globals:
#   dry_run_flag
#   email_flag
#   force_renew_flag
#   hsts_flag
#   letsencrypt_email
#   must_ocsp_staple_flag
#   ocsp_stapling_flag
#   overwrite_self_signed_certs_flag
#   productions_certs_flag
#   strict_file_permissions_flag
#   uir_flag
#   use_dry_run
#   use_force_renew
#   use_hsts
#   use_must_staple
#   use_ocsp_stapling
#   use_overwrite_self_signed_certificates
#   use_production_ssl
#   use_strict_file_permissions
#   use_uir
# Arguments:
#  None
#######################################
construct_certbot_flags() {
  email_flag=$([[ ${letsencrypt_email} == "skip" ]] && echo "--register-unsafely-without-email" || echo "--email ${letsencrypt_email}")
  productions_certs_flag=$([[ ${use_production_ssl} == "true" ]] && echo "" || echo "--staging")
  dry_run_flag=$([[ ${use_dry_run} == "true" ]] && echo "--dry-run" || echo "")
  force_renew_flag=$([[ ${use_force_renew} == "true" ]] && echo "--force-renewal" || echo "")
  overwrite_self_signed_certs_flag=$([[ ${use_overwrite_self_signed_certificates} == "true" ]] && echo "--overwrite-cert-dirs" || echo "")
  ocsp_stapling_flag=$([[ ${use_ocsp_stapling} == "true" ]] && echo "--staple-ocsp" || echo "")
  must_ocsp_staple_flag=$([[ ${use_must_staple} == "true" ]] && echo "--must-staple" || echo "")
  strict_file_permissions_flag=$([[ ${use_strict_file_permissions} == "true" ]] && echo "--strict-permissions" || echo "")
  hsts_flag=$([[ ${use_hsts} == "true" ]] && echo "--hsts" || echo "")
  uir_flag=$([[ ${use_uir} == "true" ]] && echo "--uir" || echo "")
}

#######################################
# description
# Globals:
#   use_production_ssl
# Arguments:
#  None
#######################################
handle_staging_flags() {
  if [[ -n ${use_production_ssl} ]] && [[ ${use_production_ssl} == "true" ]]; then
    print_multiple_messages "Certbot is running in production mode."
    print_multiple_messages "Removing --staging flag from docker-compose.yml..."
    remove_staging_flag
  fi
}

#######################################
# description
# Globals:
#   docker_compose_file
# Arguments:
#  None
#######################################
remove_dry_run_flag() {
  local temp_file
  print_multiple_messages "Removing --dry-run flag from docker-compose.yml..."
  temp_file=$(remove_certbot_command_flags_compose '--dry-run')
  check_flag_removal "${temp_file}" '--dry-run'
  backup_and_replace_file "${docker_compose_file}" "${temp_file}"
}

#######################################
# description
# Globals:
#   docker_compose_file
# Arguments:
#   1
#######################################
remove_certbot_command_flags_compose() {
  local flag_to_remove=$1
  local temp_file
  temp_file="$(mktemp)"

  # Perform the modification
  sed "/certbot:/,/command:/s/${flag_to_remove}//" "${docker_compose_file}" > "${temp_file}"

  # Output only the path to the temporary file
  echo "${temp_file}"
}

#######################################
# description
# Globals:
#   docker_compose_file
# Arguments:
#  None
#######################################
remove_staging_flag() {
  local temp_file
  print_multiple_messages "Removing --staging flag from docker-compose.yml..."
  temp_file=$(remove_certbot_command_flags_compose '--staging')
  check_flag_removal "${temp_file}" '--staging'
  backup_and_replace_file "${docker_compose_file}" "${temp_file}"
}

#######################################
# description
# Arguments:
#   1
#   2
#######################################
check_flag_removal() {
  local file=$1
  local flag=$2

  if grep --quiet -- "${flag}" "${file}"; then
    print_multiple_messages "${flag} removal failed."
    rm "${file}"
    exit 1
  else
    print_multiple_messages "${flag} removed successfully."
  fi
}