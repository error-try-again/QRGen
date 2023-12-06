#!/usr/bin/env bash

#######################################
# Generic function to create ports of volume yml structure depending on the type.
# Arguments:
#  None
#######################################
create_ports_or_volumes() {
  local mappings=("${@:2}") # rest of the arguments as an array

  local result=""
  local first=true
  local mapping
  for mapping in "${mappings[@]}"; do
    if [ "$first" = true ]; then
      first=false
    else
      result+=","
    fi
    result+="${mapping}"
  done

  echo "${result}"
}

#######################################
# Generates network definition for Docker Compose.
# Arguments:
#   1
#   2
#######################################
create_network_definition() {
  local network_name="$1"
  local network_driver="$2"

  local definition
  definition="networks:"
  definition+=$'\n'
  definition+="  ${network_name}:"
  definition+=$'\n'
  definition+="    driver: ${network_driver}"

  echo "${definition}"
}

#######################################
# Generates volume definition for Docker Compose.
# Globals:
#   USE_LETS_ENCRYPT
#   USE_SELF_SIGNED_CERTS
# Arguments:
#   1
#   2
#######################################
create_volume_definition() {
  local volume_name="$1"
  local volume_driver="$2"

  if [[ $USE_LETS_ENCRYPT == "yes" ]] || [[ $USE_SELF_SIGNED_CERTS == "yes" ]]; then

    local definition
    definition="volumes:"
    definition+=$'\n'
    definition+="  ${volume_name}:"
    definition+=$'\n'
    definition+="    driver: ${volume_driver}"

    echo "$definition"
  fi
}

#######################################
# Created a generic service definition for Docker Compose file.
# Globals:
#   ADDR
# Arguments:
#  None
#######################################
create_service() {
  local name=""
  local build_context=""
  local dockerfile=""
  local command=""
  local ports=""
  local volumes=""
  local networks=""
  local restart=""
  local depends=""

  # Parsing named arguments
  while [ "$#" -gt 0 ]; do
    case $1 in
      --name) name=$2; shift 2 ;;
      --build-context) build_context=$2; shift 2 ;;
      --dockerfile) dockerfile=$2; shift 2 ;;
      --command) command=$2; shift 2 ;;
      --ports) ports=$2; shift 2 ;;
      --volumes) volumes=$2; shift 2 ;;
      --networks) networks=$2; shift 2 ;;
      --restart) restart=$2; shift 2 ;;
      --depends-on) depends=$2; shift 2 ;;
      *) shift ;;
    esac
  done

  # Building the service definition
  local definition
  definition="  ${name}:"
  definition+=$'\n'
  definition+="    build:"
  definition+=$'\n'
  definition+="      context: ${build_context}"
  definition+=$'\n'
  definition+="      dockerfile: ${dockerfile}"

  if [[ -n ${command} ]]; then
    definition+=$'\n'
    definition+="    command: ${command}"
  fi

  #######################################
  # Adds a ports, volumes or networks definition to the service definition.
  # Globals:
  #   ADDR
  #   item
  # Arguments:
  #   1
  #   2
  #######################################
  add_to_definition() {
    local type=$1
    local values=$2
    if [[ -n ${values} ]]; then
      definition+=$'\n'
      definition+="    ${type}:"
      IFS=',' read -ra ADDR <<< "$values"
      local item
      for item in "${ADDR[@]}"; do
        if [[ -n $item ]]; then
          definition+=$'\n'
          definition+="      - ${item}"
        fi
      done
    fi
  }

  add_to_definition "ports" "$ports"
  add_to_definition "volumes" "$volumes"
  add_to_definition "networks" "$networks"

  if [[ -n ${restart} ]]; then
    definition+=$'\n'
    definition+="    restart: ${restart}"
  fi

  if [[ -n ${depends} ]]; then
    add_to_definition "depends_on" "$depends"
  fi

  echo "${definition}"
}


#######################################
# Creates a network definition for Docker Compose file.
# Arguments:
#   1
#######################################
specify_network() {
  local network_name="$1"

  local networks
  networks="networks:"
  networks+=$'\n'
  networks+="      - ${network_name}"

  echo "${networks}"
}

#######################################
# Pulls in global variables if they are defined to generate a certbot command.
# Globals:
#   DOMAIN_NAME
#   INTERNAL_WEBROOT_DIR
#   NON_INTERACTIVE_FLAG
#   NO_EFF_EMAIL_FLAG
#   RSA_KEY_SIZE_FLAG
#   SUBDOMAIN
#   TOS_FLAG
#   dry_run_flag
#   email_flag
#   force_renew_flag
#   hsts_flag
#   internal_dirs
#   must_staple_flag
#   ocsp_stapling_flag
#   overwrite_self_signed_certs_flag
#   production_certs_flag
#   strict_permissions_flag
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

#######################################
# Determines how the Docker Compose file should be configured depending on the user's choices.
# Globals:
#   BACKEND_PORT
#   CERTS_DH_VOLUME_MAPPING
#   CERTS_DIR
#   CHALLENGE_PORT
#   DOCKER_COMPOSE_FILE
#   DOMAIN_NAME
#   INTERNAL_WEBROOT_DIR
#   LETS_ENCRYPT_LOGS_VOLUME_MAPPING
#   LETS_ENCRYPT_VOLUME_MAPPING
#   NGINX_PORT
#   NGINX_SSL_PORT
#   RELEASE_BRANCH
#   USE_LETS_ENCRYPT
#   USE_SELF_SIGNED_CERTS
#   certbot_volume_mappings
#   default_port
#   dirs
#   internal_dirs
# Arguments:
#  None
#######################################
configure_docker_compose() {
  local backend_service_definition
  local frontend_service_definition
  local certbot_service_definition

  local network_name
  local network_driver

  local volume_name
  local volume_driver

  local volume_definition
  local network_definition

  local backend_name
  local frontend_name
  local certbot_name

  local backend_context
  local backend_dockerfile

  local frontend_context
  local frontend_dockerfile

  local certbot_context
  local certbot_dockerfile

  local backend_depends_on
  local frontend_depends_on
  local certbot_depends_on

  local backend_ports
  local frontend_ports

  local backend_restart
  local frontend_restart

  local backend_volumes
  local frontend_volumes
  local shared_certbot_volumes

  local backend_networks
  local frontend_networks
  local certbot_networks

  backend_service_definition=""
  frontend_service_definition=""
  certbot_service_definition=""

  network_name="qrgen"
  network_driver="bridge"

  volume_name="nginx-shared-volume"
  volume_driver="local"

  backend_name="backend"
  frontend_name="frontend"
  certbot_name="certbot"

  backend_context="."
  backend_dockerfile="./backend/Dockerfile"

  frontend_context="."
  frontend_dockerfile="./frontend/Dockerfile"

  certbot_context="."
  certbot_dockerfile="./certbot/Dockerfile"

  backend_depends_on=""
  frontend_depends_on="backend"
  certbot_depends_on="frontend"

  backend_ports=""
  frontend_ports=""

  backend_restart="on-failure"
  frontend_restart="on-failure"

  backend_volumes=""
  frontend_volumes=""
  shared_certbot_volumes=""

  frontend_networks=$(specify_network "$network_name")
  backend_networks="$(specify_network "$network_name")"
  certbot_networks=""

  default_port="80"

  if [[ $USE_LETS_ENCRYPT == "yes" ]]; then
    echo "Configuring Docker Compose for Let's Encrypt..."

      if [[ $RELEASE_BRANCH == "full-release" ]]; then
      backend_ports=$(create_ports_or_volumes \
        "ports" \
        "${BACKEND_PORT}:${BACKEND_PORT}")

      backend_volumes=$(create_ports_or_volumes \
        "volumes" \
        "${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/privkey.pem:/etc/ssl/certs/privkey.pem:ro" \
        "${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/fullchain.pem:/etc/ssl/certs/fullchain.pem:ro")
    fi

      frontend_ports=$(create_ports_or_volumes \
      "ports" \
      "${NGINX_PORT}:${NGINX_PORT}" \
      "${NGINX_SSL_PORT}:${NGINX_SSL_PORT}" \
      "${CHALLENGE_PORT}:${CHALLENGE_PORT}")

    shared_certbot_volumes=$(create_ports_or_volumes \
      "volumes" \
      "${certbot_volume_mappings[LETS_ENCRYPT_VOLUME_MAPPING]}" \
      "${certbot_volume_mappings[LETS_ENCRYPT_LOGS_VOLUME_MAPPING]}" \
      "${certbot_volume_mappings[CERTS_DH_VOLUME_MAPPING]}" \
      "nginx-shared-volume:${internal_dirs[INTERNAL_WEBROOT_DIR]}")

    frontend_volumes=$(create_ports_or_volumes \
      "volumes" \
      "./frontend:/usr/share/nginx/html:rw" \
      "./nginx.conf:/etc/nginx/nginx.conf:ro" \
      "${certbot_volume_mappings[LETS_ENCRYPT_VOLUME_MAPPING]}" \
      "${certbot_volume_mappings[LETS_ENCRYPT_LOGS_VOLUME_MAPPING]}" \
      "${certbot_volume_mappings[CERTS_DH_VOLUME_MAPPING]}" \
      "nginx-shared-volume:${internal_dirs[INTERNAL_WEBROOT_DIR]}")

    certbot_service_definition=$(create_service \
      --name "${certbot_name}" \
      --build-context "${certbot_context}" \
      --dockerfile "${certbot_dockerfile}" \
      --command "$(generate_certbot_command)" \
      --volumes "${shared_certbot_volumes}" \
      --networks "${certbot_networks}" \
      --depends-on "${certbot_depends_on}")

  elif [[ ${USE_SELF_SIGNED_CERTS} == "yes" ]]; then
    echo "Configuring Docker Compose for self-signed certificates..."

      if [[ ${RELEASE_BRANCH} == "full-release" ]]; then

      backend_ports=$(create_ports_or_volumes \
        "ports" \
        "${BACKEND_PORT}:${BACKEND_PORT}")

      backend_volumes=$(create_ports_or_volumes \
        "volumes" \
        "${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/privkey.pem:/etc/ssl/certs/privkey.pem:ro" \
        "${dirs[CERTS_DIR]}/live/${DOMAIN_NAME}/fullchain.pem:/etc/ssl/certs/fullchain.pem:ro")
    fi

    frontend_ports=$(create_ports_or_volumes \
      "ports" \
      "${NGINX_PORT}:${NGINX_PORT}" \
      "${NGINX_SSL_PORT}:${NGINX_SSL_PORT}")

    frontend_volumes=$(create_ports_or_volumes \
      "volumes" \
      "./nginx.conf:/etc/nginx/nginx.conf:ro" \
      "${certbot_volume_mappings[LETS_ENCRYPT_VOLUME_MAPPING]}" \
      "${certbot_volume_mappings[LETS_ENCRYPT_LOGS_VOLUME_MAPPING]}" \
      "${certbot_volume_mappings[CERTS_DH_VOLUME_MAPPING]}")

  else
    echo "Configuring Docker Compose for HTTP..."

    if [[ ${RELEASE_BRANCH} == "full-release" ]]; then
      backend_ports=$(create_ports_or_volumes \
        "ports" \
        "${BACKEND_PORT}:${BACKEND_PORT}")
    fi

    frontend_ports=$(create_ports_or_volumes \
        "ports" \
        "${NGINX_PORT}:${default_port}")
  fi

  backend_service_definition=$(create_service \
    --name "${backend_name}" \
    --build-context "${backend_context}" \
    --dockerfile "${backend_dockerfile}" \
    --ports "${backend_ports}" \
    --volumes "${backend_volumes}" \
    --networks "${backend_networks}" \
    --restart "${backend_restart}" \
    --depends-on "${backend_depends_on}")

  frontend_service_definition=$(create_service \
    --name "${frontend_name}" \
    --build-context "${frontend_context}" \
    --dockerfile "${frontend_dockerfile}" \
    --ports "${frontend_ports}" \
    --volumes "${frontend_volumes}" \
    --networks "${frontend_networks}" \
    --restart "${frontend_restart}" \
    --depends-on "${frontend_depends_on}")

  network_definition=$(create_network_definition \
    "${network_name}" \
    "${network_driver}")

  volume_definition=$(create_volume_definition \
    "${volume_name}" \
    "${volume_driver}")

  {
    echo "version: '3.8'"
    echo "services:"
    echo "${backend_service_definition}"
    echo "${frontend_service_definition}"
    echo "${certbot_service_definition}"
    echo "${network_definition}"
    echo "${volume_definition}"
  } > "${DOCKER_COMPOSE_FILE}"

  cat "${DOCKER_COMPOSE_FILE}"
  echo "Docker Compose configuration written to ${DOCKER_COMPOSE_FILE}"
}
