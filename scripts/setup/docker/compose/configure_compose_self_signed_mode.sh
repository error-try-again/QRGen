#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Configures Docker Compose services for self-signed SSL.
# This function sets up necessary port mappings, volume mappings,
# and service definitions for running with self-signed certificates.
# Globals:
#   BACKEND_PORT
#   CERTS_DH_VOLUME_MAPPING
#   CERTS_DIR
#   DOMAIN_NAME
#   EXPOSED_NGINX_PORT
#   INTERNAL_NGINX_PORT
#   LETSENCRYPT_LOGS_VOLUME_MAPPING
#   LETSENCRYPT_VOLUME_MAPPING
#   NGINX_SSL_PORT
#   RELEASE_BRANCH
#   backend_volumes
# Arguments:
#  None
#######################################
function configure_compose_self_signed_mode() {
  print_messages "Configuring Docker Compose for self-signed certificates..."

  if [[ ${RELEASE_BRANCH} == "full-release" ]]; then
    backend_ports=$(join_with_commas \
      "ports" \
      "${BACKEND_PORT}:${BACKEND_PORT}")

    backend_volumes=$(join_with_commas \
      "volumes" \
      "${CERTS_DIR}/live/${DOMAIN_NAME}/privkey.pem:/etc/ssl/certs/privkey.pem:ro" \
      "${CERTS_DIR}/live/${DOMAIN_NAME}/fullchain.pem:/etc/ssl/certs/fullchain.pem:ro")
  fi

  # Set INTERNAL_NGINX_PORT to the same value as EXPOSED_NGINX_PORT if using Self-Signed Certs
  # This is to avoid potential port conflicts with the certbot container and the nginx container if Let's Encrypt is enabled at a later date
  INTERNAL_NGINX_PORT=${EXPOSED_NGINX_PORT}

  frontend_ports=$(join_with_commas \
    "ports" \
    "${EXPOSED_NGINX_PORT}:${INTERNAL_NGINX_PORT}" \
    "${NGINX_SSL_PORT}:${NGINX_SSL_PORT}")

  frontend_volumes=$(join_with_commas \
    "volumes" \
    "./nginx.conf:/etc/nginx/nginx.conf:ro" \
    "${LETSENCRYPT_VOLUME_MAPPING}" \
    "${LETSENCRYPT_LOGS_VOLUME_MAPPING}" \
    "${CERTS_DH_VOLUME_MAPPING}")
}
