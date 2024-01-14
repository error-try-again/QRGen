#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Sets up the backend service definition.
# Calls join_with_commas to join the ports and volumes arrays
# into a comma-separated string of arguments.
# Globals:
#   BACKEND_PORT
#   CERTS_DIR
#   DOMAIN_NAME
#   RELEASE_BRANCH
#   backend_ports
#   backend_volumes
# Arguments:
#  None
#######################################
function setup_backend() {
  if [[ ${RELEASE_BRANCH} == "full-release" ]]; then
    express_ports=$(join_with_commas \
      "ports" \
      "${EXPRESS_PORT}:${EXPRESS_PORT}")

    # export to ensure that the variable is available in the assemble script
    export express_ports

    express_volumes=$(join_with_commas \
      "volumes" \
      "${CERTS_DIR}/live/${DOMAIN_NAME}/privkey.pem:/etc/ssl/certs/privkey.pem:ro" \
      "${CERTS_DIR}/live/${DOMAIN_NAME}/fullchain.pem:/etc/ssl/certs/fullchain.pem:ro")
  fi
}

#######################################
# Sets up the frontend service definition.
# Calls join_with_commas to join the ports and volumes arrays
# into a comma-separated string of arguments.
# Globals:
#   CERTS_DH_VOLUME_MAPPING
#   CHALLENGE_PORT
#   EXPOSED_NGINX_PORT
#   INTERNAL_NGINX_PORT
#   INTERNAL_WEBROOT_DIR
#   LETSENCRYPT_LOGS_VOLUME_MAPPING
#   LETSENCRYPT_VOLUME_MAPPING
#   NGINX_SSL_PORT
#   frontend_ports
#   frontend_volumes
# Arguments:
#  None
#######################################
function setup_frontend() {
  INTERNAL_NGINX_PORT=${EXPOSED_NGINX_PORT}

  frontend_ports=$(join_with_commas \
    "ports" \
    "${EXPOSED_NGINX_PORT}:${INTERNAL_NGINX_PORT}" \
    "${NGINX_SSL_PORT}:${NGINX_SSL_PORT}" \
    "${CHALLENGE_PORT}:${CHALLENGE_PORT}")

  # export to ensure that the variable is available in the assemble script
  export frontend_ports

  frontend_volumes=$(join_with_commas \
    "volumes" \
    "./frontend:/usr/share/nginx/html:rw" \
    "./nginx.conf:/etc/nginx/nginx.conf:ro" \
    "${LETSENCRYPT_VOLUME_MAPPING}" \
    "${LETSENCRYPT_LOGS_VOLUME_MAPPING}" \
    "${CERTS_DH_VOLUME_MAPPING}" \
    "nginx-shared-volume:${INTERNAL_WEBROOT_DIR}")
}

#######################################
# Sets up the certbot service definition.
# Calls generate_certonly_command to generate the command
# to run certbot with.
# Calls join_with_commas to join the ports and volumes arrays
# into a comma-separated string of arguments.
# Globals:
#   CERTS_DH_VOLUME_MAPPING
#   INTERNAL_WEBROOT_DIR
#   LETSENCRYPT_LOGS_VOLUME_MAPPING
#   LETSENCRYPT_VOLUME_MAPPING
#   certbot_context
#   certbot_depends_on
#   certbot_dockerfile
#   certbot_name
#   certbot_networks
#   certbot_service_definition
#   certbot_volumes
# Arguments:
#  None
#######################################
function setup_certbot() {
  certbot_volumes=$(join_with_commas \
    "volumes" \
    "${LETSENCRYPT_VOLUME_MAPPING}" \
    "${LETSENCRYPT_LOGS_VOLUME_MAPPING}" \
    "${CERTS_DH_VOLUME_MAPPING}" \
    "nginx-shared-volume:${INTERNAL_WEBROOT_DIR}")

  local certbot_command
  certbot_command=$(generate_certonly_command)

  certbot_service_definition=$(create_service_definition \
    --name "${certbot_name}" \
    --build-context "${certbot_context}" \
    --dockerfile "${certbot_dockerfile}" \
    --command "${certbot_command}" \
    --volumes "${certbot_volumes}" \
    --networks "${certbot_networks}" \
    --depends-on "${certbot_depends_on}")
}

#######################################
# Configures Docker Compose services for Let's Encrypt SSL.
# This function sets up necessary port mappings, volume mappings,
# and service definitions for running with Let's Encrypt certificates.
# Arguments:
#  None
#######################################
function configure_compose_letsencrypt_mode() {
  print_messages "Configuring Docker Compose for Let's Encrypt..."
  setup_backend
  setup_frontend
  setup_certbot
}
