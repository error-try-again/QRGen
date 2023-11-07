#!/bin/bash

configure_docker_compose() {

  local CERTBOT_LETS_ENCRYPT_VOLUME_MAPPING="${CERTBOT_VOLUME_MAPPINGS[LETS_ENCRYPT_VOLUME_MAPPING]}"
  local CERTBOT_LETS_ENCRYPT_LOGS_VOLUME_MAPPING="${CERTBOT_VOLUME_MAPPINGS[LETS_ENCRYPT_LOGS_VOLUME_MAPPING]}"
  local CERTBOT_CERTS_DH_VOLUME_MAPPING="${CERTBOT_VOLUME_MAPPINGS[CERTS_DH_VOLUME_MAPPING]}"

  local USE_BACKEND="yes"
  local USE_FRONTEND="yes"
  local use_shared_volume=""

  local http01_challenge_ports=""
  local shared_volume=""

  local backend_service=""
  local frontend_service=""
  local certbot_service=""

  local certbot_command=""
  local with_email

  local use_bridge_network="
networks:
  qrgen:
    driver: bridge"

  if [[ "$USE_LETS_ENCRYPT" == "yes" ]]; then

    local use_shared_volume="
volumes:
  nginx-shared-volume:
    driver: local"

    shared_volume="- nginx-shared-volume:${INTERNAL_DIRS[INTERNAL_WEBROOT_DIR]}"

    prompt_for_letsencrypt_email
    prompt_for_ssl_environment
    prompt_for_dry_run

    if [[ "$USE_CUSTOM_DOMAIN" == "yes" && "$LETSENCRYPT_EMAIL" != "" ]]; then
      with_email="--email ${LETSENCRYPT_EMAIL}"
    else
      with_email="${WITHOUT_EMAIL}"
    fi

    certbot_command="certonly --webroot
    --webroot-path=${INTERNAL_DIRS[INTERNAL_WEBROOT_DIR]} ${with_email} ${TOS}
    ${NO_EFF_EMAIL} ${KEEP_UNTIL_EXPIRY} ${FORCE_RENEWAL}  ${RSA_KEY_SIZE_FLAG} --domains ${DOMAIN_NAME} --domains ${SUBDOMAIN}.${DOMAIN_NAME}"

    if [[ $USE_PRODUCTION_SSL == "no" ]]; then
      certbot_command+=" ${STAGING_FLAG}"
    fi

    if [[ $DRY_RUN_FLAG == "yes" ]]; then
      certbot_command+=" ${DRY_RUN_FLAG}"
    fi

    certbot_service="certbot:
    image: certbot/certbot
    command: ${certbot_command}
    volumes:
      - ${CERTBOT_LETS_ENCRYPT_VOLUME_MAPPING}:rw
      - ${CERTBOT_LETS_ENCRYPT_LOGS_VOLUME_MAPPING}:rw
      - ${CERTBOT_CERTS_DH_VOLUME_MAPPING}:ro
      $shared_volume:rw
    depends_on:
    - frontend"
  fi

  if [[ "$USE_BACKEND" == "yes" ]]; then
    backend_service="backend:
    build:
      context: .
      dockerfile: ./backend/Dockerfile
    ports:
      - \"${BACKEND_PORT}:${BACKEND_PORT}\"
    networks:
      - qrgen"
  fi

  if [[ "$USE_FRONTEND" == "yes" ]]; then

    if [[ "$USE_LETS_ENCRYPT" == "yes" ]]; then
      http01_challenge_ports="- \"${NGINX_SSL_PORT}:${NGINX_SSL_PORT}\""
      http01_challenge_ports+=$'\n      - "80:80"'
    fi

    frontend_service="frontend:
    build:
      context: .
      dockerfile: ./frontend/Dockerfile
    ports:
      - \"${NGINX_PORT}:${NGINX_PORT}\"
      $http01_challenge_ports
    networks:
      - qrgen
    volumes:
      - ./frontend:/usr/app
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ${NGINX_VOLUME_MAPPINGS[CERTS_VOLUME_MAPPING]}:rw
      - ${NGINX_VOLUME_MAPPINGS[DH_VOLUME_MAPPING]}:ro
      $shared_volume
    depends_on:
      - backend"
  fi

  cat <<-EOF >"${PROJECT_ROOT_DIR}/docker-compose.yml"
version: '3.8'
services:
  $backend_service
  $frontend_service
  $certbot_service
$use_bridge_network
$use_shared_volume
EOF

  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to write Docker Compose configuration."
    return 1
  fi

  cat "${PROJECT_ROOT_DIR}"/docker-compose.yml
  echo "Docker Compose configuration written to ${PROJECT_ROOT_DIR}/docker-compose.yml"
}
