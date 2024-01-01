#!/usr/bin/env bash
# bashsupport disable=BP5006

#######################################
# Configures Docker Compose services depending on the selected SSL mode.
# Globals:
#   USE_LETSENCRYPT
#   USE_SELF_SIGNED_CERTS
# Arguments:
#  None
#######################################
function generate_docker_compose() {
  print_messages "Configuring Docker Compose..."
  initialize_variables
  backup_existing_config "${DOCKER_COMPOSE_FILE}"
  if [[ ${USE_LETSENCRYPT} == "true" ]]; then
    configure_compose_letsencrypt_mode
  elif [[ ${USE_SELF_SIGNED_CERTS} == "true" ]]; then
    echo "Configuring Docker Compose for self-signed certificates...!!!"
    configure_compose_self_signed_mode
  else
    configure_http
  fi
  # Assemble the Docker Compose configuration
  assemble_docker_compose_configuration
}
