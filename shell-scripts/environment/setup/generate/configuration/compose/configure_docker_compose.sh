#!/bin/bash

################################################
# Sets up the Docker Compose configuration for the application.
# This includes configuring services for the backend, frontend, and optionally Certbot for Let's Encrypt SSL.
#
# Globals:
#   CERTBOT_VOLUME_MAPPINGS, CERTS_DH_VOLUME_MAPPING, INTERNAL_WEBROOT_DIR,
#   LETS_ENCRYPT_LOGS_VOLUME_MAPPING, LETS_ENCRYPT_VOLUME_MAPPING,
#   NGINX_SSL_PORT, PROJECT_ROOT_DIR, USE_LETS_ENCRYPT
#   certbot_volume_mappings, internal_dirs
# Arguments:
#   None
################################################
configure_docker_compose() {
  # Local variables for service definitions and volume mappings
  local certbot_service_definition=""
  local http01_ports=""
  local frontend_certbot_shared_volume=""
  local certs_volume=""

  # Configure for Let's Encrypt if enabled
  if [[ $USE_LETS_ENCRYPT == "yes" ]]; then
    echo "Configuring Docker Compose for Let's Encrypt..."

    # Ports for HTTP-01 challenge
    http01_ports="- \"${NGINX_SSL_PORT}:${NGINX_SSL_PORT}\""
    http01_ports+=$'\n      - "80:80"'

    # Shared volumes for Let's Encrypt and SSL certificates
    frontend_certbot_shared_volume="- nginx-shared-volume:${internal_dirs[INTERNAL_WEBROOT_DIR]}"
    frontend_certbot_shared_volume+=$'\n      - '${certbot_volume_mappings[LETS_ENCRYPT_VOLUME_MAPPING]}
    frontend_certbot_shared_volume+=$'\n      - '${certbot_volume_mappings[LETS_ENCRYPT_LOGS_VOLUME_MAPPING]}
    frontend_certbot_shared_volume+=$'\n      - '${certbot_volume_mappings[CERTS_DH_VOLUME_MAPPING]}

    certs_volume="    volumes:"
    certs_volume+=$'\n      - '${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/privkey.pem:/etc/ssl/certs/privkey.pem:ro
    certs_volume+=$'\n      - '${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/fullchain.pem:/etc/ssl/certs/fullchain.pem:ro

    # Generate Certbot service definition
    certbot_service_definition=$(create_certbot_service "$(generate_certbot_command)" "$frontend_certbot_shared_volume")

  elif [[ $USE_SELF_SIGNED_CERTS == "yes" ]]; then
    echo "Configuring Docker Compose for self-signed certificates..."

    http01_ports="- \"${NGINX_SSL_PORT}:${NGINX_SSL_PORT}\""
    http01_ports+=$'\n      - "80:80"'

    frontend_certbot_shared_volume+=$'\n      - '${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/privkey.pem:/etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem:ro
    frontend_certbot_shared_volume+=$'\n      - '${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/fullchain.pem:/etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem:ro
    frontend_certbot_shared_volume+=$'\n      - '${dirs[CERTS_DH_DIR]}:${internal_dirs[INTERNAL_CERTS_DH_DIR]}:ro

    certs_volume="    volumes:"
    certs_volume+=$'\n      - '${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/privkey.pem:/etc/ssl/certs/privkey.pem:ro
    certs_volume+=$'\n      - '${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/fullchain.pem:/etc/ssl/certs/fullchain.pem:ro

  else
    echo "Configuring Docker Compose without SSL certificates..."
  fi

  local backend_section
  local frontend_section
  local network_section
  local volume_section

  # Assembling Docker Compose sections
  backend_section=$(create_backend_service "$certs_volume")
  frontend_section=$(create_frontend_service "$http01_ports" "$frontend_certbot_shared_volume")
  network_section=$(create_network_definition)
  volume_section=$(create_volume_definition)

  # Write Docker Compose file
  {
    echo "version: '3.8'"
    echo "services:"
    echo "$backend_section"
    echo "$frontend_section"
    echo "$certbot_service_definition"
    echo "$network_section"
    echo "$volume_section"
  } > "${PROJECT_ROOT_DIR}/docker-compose.yml"

  # Display the generated Docker Compose file
  cat "${PROJECT_ROOT_DIR}/docker-compose.yml"
  echo "Docker Compose configuration written to ${PROJECT_ROOT_DIR}/docker-compose.yml"
}

################################################
# Generates the command to be used with Certbot for SSL certificate generation.
#
# Globals:
#   FORCE_RENEWAL_FLAG, INTERNAL_WEBROOT_DIR, NON_INTERACTIVE_FLAG,
#   NO_EFF_EMAIL_FLAG, RSA_KEY_SIZE_FLAG, TOS_FLAG, DOMAIN_NAME,
#   dry_run_flag, email_flag, hsts_flag, internal_dirs, must_staple_flag,
#   ocsp_stapling_flag, overwrite_self_signed_certs_flag, production_certs_flag,
#   strict_permissions_flag, SUBDOMAIN, uir_flag
# Arguments:
#   None
################################################
generate_certbot_command() {
  echo "certonly \
--webroot \
--webroot-path=${internal_dirs[INTERNAL_WEBROOT_DIR]} \
${email_flag} \
${TOS_FLAG} \
${NO_EFF_EMAIL_FLAG} \
${NON_INTERACTIVE_FLAG} \
${FORCE_RENEWAL_FLAG} \
${RSA_KEY_SIZE_FLAG} \
${hsts_flag} \
${must_staple_flag} \
${uir_flag} \
${ocsp_stapling_flag} \
${strict_permissions_flag} \
${production_certs_flag} \
${dry_run_flag} \
${overwrite_self_signed_certs_flag}" \
    --domains "${DOMAIN_NAME}" \
    --domains "$SUBDOMAIN"."${DOMAIN_NAME}"
}

#######################################
# Generates the backend service definition for Docker Compose.
# Globals:
#   BACKEND_PORT
# Arguments:
#   1
#######################################
create_backend_service() {
  local volume_section=$1
  echo "  backend:
    build:
      context: .
      dockerfile: ./backend/Dockerfile
    ports:
      - \"${BACKEND_PORT}:${BACKEND_PORT}\"
    networks:
      - qrgen
$volume_section"
}

#######################################
# Generates the frontend service definition for Docker Compose.
# Globals:
#   NGINX_PORT
# Arguments:
#   1
#   2
#######################################
create_frontend_service() {
  local ports_section=$1
  local volume_section=$2
  echo "  frontend:
    build:
      context: .
      dockerfile: ./frontend/Dockerfile
    ports:
      - \"${NGINX_PORT}:${NGINX_PORT}\"
      $ports_section
    networks:
      - qrgen
    volumes:
      - ./frontend:/usr/share/nginx/html:ro
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      $volume_section
    depends_on:
      - backend"
}

#######################################
# Generates the Certbot service definition for Docker Compose.
# Arguments:
#   1
#   2
#######################################
create_certbot_service() {
  local command=$1
  local volumes=$2
  echo "  certbot:
    build:
      context: .
      dockerfile: ./certbot/Dockerfile
    command: $command
    volumes:
      $volumes
    depends_on:
      - frontend"
}

#######################################
# Generates the network definition for Docker Compose.
# Arguments:
#  None
#######################################
create_network_definition() {
  echo "networks:
  qrgen:
    driver: bridge"
}

#######################################
# Generates the volume definition for Docker Compose depending on whether SSL certificates are enabled.
# Globals:
#   USE_LETS_ENCRYPT
# Arguments:
#  None
#######################################
create_volume_definition() {
  if [[ $USE_LETS_ENCRYPT == "yes" ]] || [[ $USE_SELF_SIGNED_CERTS == "yes" ]]; then
    echo "volumes:
  nginx-shared-volume:
    driver: local"
  fi
}
