#!/bin/bash

#######################################
# description
# Globals:
#   CERTBOT_VOLUME_MAPPINGS
#   CERTS_DH_VOLUME_MAPPING
#   INTERNAL_WEBROOT_DIR
#   LETS_ENCRYPT_LOGS_VOLUME_MAPPING
#   LETS_ENCRYPT_VOLUME_MAPPING
#   NGINX_SSL_PORT
#   PROJECT_ROOT_DIR
#   USE_LETS_ENCRYPT
#   certbot_volume_mappings
#   internal_dirs
# Arguments:
#  None
#######################################
configure_docker_compose() {

  local http01_challenge_ports=""
  local shared_volume=""

  if [[ $USE_LETS_ENCRYPT == "yes" ]]; then

    echo "Configuring Docker Compose for Let's Encrypt..."
    http01_challenge_ports="- \"${NGINX_SSL_PORT}:${NGINX_SSL_PORT}\""
    http01_challenge_ports+=$'\n      - "80:80"'

    shared_volume="- nginx-shared-volume:${internal_dirs[INTERNAL_WEBROOT_DIR]}"
    shared_volume+=$'\n      - '${certbot_volume_mappings[LETS_ENCRYPT_VOLUME_MAPPING]}
    shared_volume+=$'\n      - '${certbot_volume_mappings[LETS_ENCRYPT_LOGS_VOLUME_MAPPING]}
    shared_volume+=$'\n      - '${certbot_volume_mappings[CERTS_DH_VOLUME_MAPPING]}
  fi

  local backend_section
  local frontend_section
  local certbot_section
  local network_section
  local volume_section

  backend_section=$(create_backend_service)
  frontend_section=$(create_frontend_service "$http01_challenge_ports" "$shared_volume")
  certbot_section=$(create_certbot_service "$(generate_certbot_command)" "$shared_volume")
  network_section=$(create_network_definition)
  volume_section=$(create_volume_definition)

  {
    echo "version: '3.8'"
    echo "services:"
    echo "$backend_section"
    echo "$frontend_section"
    echo "$certbot_section"
    echo "$network_section"
    echo "$volume_section"
  } > "${PROJECT_ROOT_DIR}/docker-compose.yml"

  cat "${PROJECT_ROOT_DIR}/docker-compose.yml"
  echo "Docker Compose configuration written to ${PROJECT_ROOT_DIR}/docker-compose.yml"
}

#######################################
# description
# Globals:
#   FORCE_RENEWAL_FLAG
#   INTERNAL_WEBROOT_DIR
#   NON_INTERACTIVE_FLAG
#   NO_EFF_EMAIL_FLAG
#   RSA_KEY_SIZE_FLAG
#   TOS_FLAG
#   domain_name
#   dry_run_flag
#   email_flag
#   hsts_flag
#   internal_dirs
#   must_staple_flag
#   ocsp_stapling_flag
#   overwrite_self_signed_certs_flag
#   production_certs_flag
#   strict_permissions_flag
#   subdomain
#   uir_flag
# Arguments:
#  None
#######################################
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
--domains ${domain_name} \
--domains ${subdomain}.${domain_name} \
${overwrite_self_signed_certs_flag}"
}

#######################################
# description
# Globals:
#   BACKEND_PORT
# Arguments:
#  None
#######################################
create_backend_service() {
  echo "  backend:
    build:
      context: .
      dockerfile: ./backend/Dockerfile
    ports:
      - \"${BACKEND_PORT}:${BACKEND_PORT}\"
    networks:
      - qrgen"
}

#######################################
# description
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
      - ./frontend:/usr/share/nginx/html
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      $volume_section
    depends_on:
      - backend"
}

#######################################
# description
# Arguments:
#   1
#   2
#######################################
create_certbot_service() {

  local command=$1
  local volumes=$2
  echo "  certbot:
    image: certbot/certbot
    command: $command
    volumes:
      $volumes
    depends_on:
      - frontend"
}

#######################################
# description
# Arguments:
#  None
#######################################
create_network_definition() {
  echo "networks:
  qrgen:
    driver: bridge"
}

#######################################
# description
# Globals:
#   USE_LETS_ENCRYPT
# Arguments:
#  None
#######################################
create_volume_definition() {
  if [[ $USE_LETS_ENCRYPT == "yes" ]]; then
    echo "volumes:
  nginx-shared-volume:
    driver: local"
  fi
}
