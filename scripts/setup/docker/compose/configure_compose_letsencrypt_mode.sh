#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Configures Docker Compose services for Let's Encrypt SSL.
# This function sets up necessary port mappings, volume mappings,
# and service definitions for running with Let's Encrypt certificates.
# Globals:
#   BACKEND_PORT - Port for the backend service.
#   CERTS_DH_VOLUME_MAPPING - Volume mapping for DH parameters.
#   CERTS_DIR - Directory containing certificates.
#   CHALLENGE_PORT - Port for Let's Encrypt challenges.
#   DOMAIN_NAME - Domain name for the SSL certificate.
#   EXPOSED_NGINX_PORT - Exposed port for Nginx.
#   INTERNAL_NGINX_PORT - Internal port for Nginx.
#   INTERNAL_WEBROOT_DIR - Directory for the webroot.
#   LETSENCRYPT_LOGS_VOLUME_MAPPING - Volume mapping for Let's Encrypt logs.
#   LETSENCRYPT_VOLUME_MAPPING - Volume mapping for Let's Encrypt configurations.
#   NGINX_SSL_PORT - SSL port for Nginx.
#   RELEASE_BRANCH - The release branch type (e.g., full-release).
# Arguments:
#   None
#######################################
function configure_compose_letsencrypt_mode() {
  echo "Configuring Docker Compose for Let's Encrypt..."

  if [[ $RELEASE_BRANCH == "full-release" ]]; then
    backend_ports=$(join_with_commas \
      "ports" \
      "${BACKEND_PORT}:${BACKEND_PORT}")

    backend_volumes=$(join_with_commas \
      "volumes" \
      "${CERTS_DIR}/live/${DOMAIN_NAME}/privkey.pem:/etc/ssl/certs/privkey.pem:ro" \
      "${CERTS_DIR}/live/${DOMAIN_NAME}/fullchain.pem:/etc/ssl/certs/fullchain.pem:ro")
  fi

  # Set INTERNAL_NGINX_PORT to the same value as EXPOSED_NGINX_PORT if using Let's Encrypt
  # This is to avoid port conflicts with the certbot container and the nginx container
  INTERNAL_NGINX_PORT=${EXPOSED_NGINX_PORT}

  frontend_ports=$(join_with_commas \
    "ports" \
    "${EXPOSED_NGINX_PORT}:${INTERNAL_NGINX_PORT}" \
    "${NGINX_SSL_PORT}:${NGINX_SSL_PORT}" \
    "${CHALLENGE_PORT}:${CHALLENGE_PORT}")

  certbot_volumes=$(join_with_commas \
    "volumes" \
    "${LETSENCRYPT_VOLUME_MAPPING}" \
    "${LETSENCRYPT_LOGS_VOLUME_MAPPING}" \
    "${CERTS_DH_VOLUME_MAPPING}" \
    "nginx-shared-volume:${INTERNAL_WEBROOT_DIR}")

  frontend_volumes=$(join_with_commas \
    "volumes" \
    "./frontend:/usr/share/nginx/html:rw" \
    "./nginx.conf:/etc/nginx/nginx.conf:ro" \
    "${LETSENCRYPT_VOLUME_MAPPING}" \
    "${LETSENCRYPT_LOGS_VOLUME_MAPPING}" \
    "${CERTS_DH_VOLUME_MAPPING}" \
    "nginx-shared-volume:${INTERNAL_WEBROOT_DIR}")

  certbot_service_definition=$(create_service_definition \
    --name "${certbot_name}" \
    --build-context "${certbot_context}" \
    --dockerfile "${certbot_dockerfile}" \
    --command "$(generate_certonly_command)" \
    --volumes "${certbot_volumes}" \
    --networks "${certbot_networks}" \
    --depends-on "${certbot_depends_on}")
}
