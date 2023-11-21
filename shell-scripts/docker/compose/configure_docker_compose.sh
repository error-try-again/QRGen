#!/bin/bash

configure_docker_compose() {
  # Network-related declarations and assignments
  local network_name
  network_name="qrgen"

  local network_driver
  network_driver="bridge"

  # Volume-related declarations and assignments
  local volume_name
  volume_name="nginx-shared-volume"

  local volume_driver
  volume_driver="local"

  # Service names declarations and assignments
  local backend_name
  backend_name="backend"

  local frontend_name
  frontend_name="frontend"

  local certbot_name
  certbot_name="certbot"

  # Backend Dockerfile declarations and assignments
  local backend_context
  backend_context="."

  local backend_dockerfile
  backend_dockerfile="./backend/Dockerfile"

  # Frontend Dockerfile declarations and assignments
  local frontend_context
  frontend_context="."

  local frontend_dockerfile
  frontend_dockerfile="./frontend/Dockerfile"

  # Certbot Dockerfile declarations and assignments
  local certbot_context
  certbot_context="."

  local certbot_dockerfile
  certbot_dockerfile="./certbot/Dockerfile"

  # Ports and volumes declarations
  local backend_ports
  backend_ports="ports:"
  backend_ports+=$'\n'
  backend_ports+="      - \"${BACKEND_PORT}:${BACKEND_PORT}\""

  local frontend_ports
  frontend_ports=""

  local frontend_volumes
  frontend_volumes=""

  local backend_volumes
  backend_volumes=""

  local shared_volumes
  shared_volumes=""

  # Service definition declarations
  local certbot_service_definition
  certbot_service_definition=""

  # Network configurations for services
  local frontend_networks
  frontend_networks=$(specify_network $network_name)

  local backend_networks
  backend_networks="$(specify_network $network_name)"

  # Dependency declarations
  local backend_depends_on
  backend_depends_on=""

  local frontend_depends_on
  frontend_depends_on="backend"

  local certbot_depends_on
  certbot_depends_on="frontend"

  if [[ $USE_LETS_ENCRYPT == "yes" ]]; then
    echo "Configuring Docker Compose for Let's Encrypt..."
    frontend_ports+="ports:"
    frontend_ports+=$'\n'
    frontend_ports+="     - \"${NGINX_PORT}:${NGINX_PORT}\""
    frontend_ports+=$'\n'
    frontend_ports+="     - \"${NGINX_SSL_PORT}:${NGINX_SSL_PORT}\""

    shared_volumes+="volumes:"
    shared_volumes+=$'\n'
    shared_volumes+="      - ${certbot_volume_mappings[LETS_ENCRYPT_VOLUME_MAPPING]}"
    shared_volumes+=$'\n'
    shared_volumes+="      - ${certbot_volume_mappings[LETS_ENCRYPT_LOGS_VOLUME_MAPPING]}"
    shared_volumes+=$'\n'
    shared_volumes+="      - ${certbot_volume_mappings[CERTS_DH_VOLUME_MAPPING]}"
    shared_volumes+=$'\n'
    shared_volumes+="      - nginx-shared-volume:${internal_dirs[INTERNAL_WEBROOT_DIR]}"

    frontend_volumes+="volumes:"
    frontend_volumes+=$'\n'
    frontend_volumes+="      - ./frontend:/usr/share/nginx/html"
    frontend_volumes+=$'\n'
    frontend_volumes+="      - ./nginx.conf:/etc/nginx/nginx.conf:ro"
    frontend_volumes+=$'\n'
    frontend_volumes+="      - ${certbot_volume_mappings[LETS_ENCRYPT_VOLUME_MAPPING]}"
    frontend_volumes+=$'\n'
    frontend_volumes+="      - ${certbot_volume_mappings[LETS_ENCRYPT_LOGS_VOLUME_MAPPING]}"
    frontend_volumes+=$'\n'
    frontend_volumes+="      - ${certbot_volume_mappings[CERTS_DH_VOLUME_MAPPING]}"
    frontend_volumes+=$'\n'
    frontend_volumes+="      - nginx-shared-volume:${internal_dirs[INTERNAL_WEBROOT_DIR]}"

    backend_volumes="volumes:"
    backend_volumes+=$'\n'
    backend_volumes+=$'      - '${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/privkey.pem:/etc/ssl/certs/privkey.pem:ro
    backend_volumes+=$'\n'
    backend_volumes+=$'      - '${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/fullchain.pem:/etc/ssl/certs/fullchain.pem:ro

    certbot_service_definition=$(
      create_certbot_service \
        $certbot_name \
        $certbot_context \
        $certbot_dockerfile \
        "$(generate_certbot_command)" \
        "$shared_volumes" \
        $certbot_depends_on
    )

  elif [[ $USE_SELF_SIGNED_CERTS == "yes" ]]; then
    echo "Configuring Docker Compose for self-signed certificates..."

    frontend_ports="ports:"
    frontend_ports+=$'\n'
    frontend_ports+="      - \"${NGINX_PORT}:${NGINX_PORT}\""
    frontend_ports+=$'\n'
    frontend_ports+="      - \"${NGINX_SSL_PORT}:${NGINX_SSL_PORT}\""

    frontend_volumes+="volumes:"
    frontend_volumes+=$'\n'
    frontend_volumes+="      - ./nginx.conf:/etc/nginx/nginx.conf:ro"
    frontend_volumes+=$'\n'
    frontend_volumes+="      - ${certbot_volume_mappings[LETS_ENCRYPT_VOLUME_MAPPING]}"
    frontend_volumes+=$'\n'
    frontend_volumes+="      - ${certbot_volume_mappings[LETS_ENCRYPT_LOGS_VOLUME_MAPPING]}"
    frontend_volumes+=$'\n'
    frontend_volumes+="      - ${certbot_volume_mappings[CERTS_DH_VOLUME_MAPPING]}"

    backend_volumes="volumes:"
    backend_volumes+=$'\n'
    backend_volumes+=$'      - '${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/privkey.pem:/etc/ssl/certs/privkey.pem:ro
    backend_volumes+=$'\n'
    backend_volumes+=$'      - '${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/fullchain.pem:/etc/ssl/certs/fullchain.pem:ro

  else
    frontend_ports="ports:"
    frontend_ports+=$'\n'
    frontend_ports+="      - \"${NGINX_PORT}:80\""

    backend_volumes="volumes:"
    backend_volumes+=$'\n'
    backend_volumes+=$'      - '${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/privkey.pem:/etc/ssl/certs/privkey.pem:ro
    backend_volumes+=$'\n'
    backend_volumes+=$'      - '${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/fullchain.pem:/etc/ssl/certs/fullchain.pem:ro
  fi

  local backend_service_definition
  local frontend_service_definition
  local network_definition
  local volume_definition

  backend_service_definition=$(
    create_backend_service \
      $backend_name \
      $backend_context \
      $backend_dockerfile \
      "$backend_ports" \
      "$backend_volumes" \
      "$backend_networks"
  )

  frontend_service_definition=$(
    create_frontend_service \
      $frontend_name \
      $frontend_context \
      $frontend_dockerfile \
      "$frontend_ports" \
      "$frontend_volumes" \
      "$frontend_networks" \
      "$frontend_depends_on"
  )

  network_definition=$(create_network_definition \
    $network_name \
    $network_driver)

  volume_definition=$(create_volume_definition \
    $volume_name \
    $volume_driver)

  {
    echo "version: '3.8'"
    echo "services:"
    echo "$backend_service_definition"
    echo "$frontend_service_definition"
    echo "$certbot_service_definition"
    echo "$network_definition"
    echo "$volume_definition"
  } > "${DOCKER_COMPOSE_FILE}"

  cat "${DOCKER_COMPOSE_FILE}"
  echo "Docker Compose configuration written to ${DOCKER_COMPOSE_FILE}"
}

generate_certbot_command() {
  echo "certonly \
--webroot \
--webroot-path=${internal_dirs[INTERNAL_WEBROOT_DIR]} \
${email_flag} \
${TOS_FLAG} \
${NO_EFF_EMAIL_FLAG} \
${NON_INTERACTIVE_FLAG} \
${RSA_KEY_SIZE_FLAG} \
${force_renew_flag} \
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

create_backend_service() {
  local name="$1"
  local build_context="$2"
  local dockerfile="$3"
  local ports="$4"
  local volumes="$5"
  local networks="$6"

  echo "
  ${name}:
    build:
      context: ${build_context}
      dockerfile: ${dockerfile}
    ${ports}
    ${networks}
    ${volumes}"
}

create_frontend_service() {
  local name="$1"
  local build_context="$2"
  local dockerfile="$3"
  local ports="$4"
  local volumes="$5"
  local networks="$6"
  local depends="$7"

  echo "
  ${name}:
    build:
      context: ${build_context}
      dockerfile: ${dockerfile}
    ${ports}
    ${networks}
    ${volumes}
    depends_on:
      - ${depends}"
}

create_certbot_service() {
  local name="$1"
  local build_context="$2"
  local dockerfile="$3"
  local command="$4"
  local volumes="$5"
  local depends="$6"

  echo "
  ${name}:
    build:
      context: ${build_context}
      dockerfile: ${dockerfile}
    command: ${command}
    ${volumes}
    depends_on:
      - ${depends}"
}


specify_network() {
  local network_name="$1"

  echo "
    networks:
      - ${network_name}"
}

# Generates network definition for Docker Compose.
create_network_definition() {
  local network_name="$1"
  local network_driver="$2"

  echo "
networks:
  ${network_name}:
    driver: ${network_driver}"
}

# Generates volume definition for Docker Compose.
create_volume_definition() {
  local volume_name="$1"
  local volume_driver="$2"

  if [[ $USE_LETS_ENCRYPT == "yes" ]] || [[ $USE_SELF_SIGNED_CERTS == "yes" ]]; then
    echo "
volumes:
  ${volume_name}:
    driver: ${volume_driver}"
  fi
}
