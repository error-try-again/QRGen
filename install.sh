#!/bin/bash

# A robust bash script setup with safe error handling.
set -euo pipefail # Exit on error, undefined variable, or pipe failure.
set +a            # Disable automatic export of all variables.

# Switch to the directory where the script is located to ensure
# relative paths are handled consistently.
cd "$(dirname "$0")"

# Source environment variables and function definitions from external scripts,
# allowing us to modularize and reuse code effectively.

# Load environment variables from a .env file.
. .env

# Helper scripts for setting up the project environment.
. ./shell-scripts/helpers/create-directory.sh
. ./shell-scripts/helpers/copy-server-files.sh

# Docker-related scripts to manage the container lifecycle.
. ./shell-scripts/docker/docker-compose-exists.sh
. ./shell-scripts/docker/docker-compose-down.sh
. ./shell-scripts/docker/produce-docker-logs.sh
. ./shell-scripts/docker/test-docker-env.sh

# Networking scripts to ensure the necessary ports are available for use.
. ./shell-scripts/networking/ensure-port-is-available.sh
. ./shell-scripts/networking/is-port-in-use.sh

# Environment validation and setup, to ensure the system is ready for the project.
. ./shell-scripts/environment/validation/test-xdg-runtime-dir.sh
. ./shell-scripts/environment/setup/setup-docker-rootless.sh
. ./shell-scripts/environment/setup/setup-project-directories.sh
. ./shell-scripts/environment/setup/generate-server-files.sh

# Configuration scripts to generate the necessary files for the project.
. ./shell-scripts/configuration/backend/configure-backend-tsconfig.sh
. ./shell-scripts/configuration/general/configure-dotenv.sh

# Scripts to interact with the user, gathering input as needed.
. ./shell-scripts/prompts/user-input.sh

# The main operational scripts that carry out the required tasks.
. ./shell-scripts/operations/operations.sh

declare -A DIRS=(
  [BACKEND_DIR]="${PROJECT_ROOT_DIR}/backend"
  [FRONTEND_DIR]="${PROJECT_ROOT_DIR}/frontend"
  [SERVER_DIR]="${PROJECT_ROOT_DIR}/server"
  [CERTS_DIR]="${PROJECT_ROOT_DIR}/certs"
  [WEBROOT_DIR]="${PROJECT_ROOT_DIR}/webroot"
  [CERTS_DH_DIR]="${PROJECT_ROOT_DIR}/certs/dhparam"
)

# Docker Internal Directory References
declare -A INTERNAL_DIRS=(
  [INTERNAL_LETS_ENCRYPT_DIR]="/etc/letsencrypt"
  [INTERNAL_LETS_ENCRYPT_LOGS_DIR]="/var/log/letsencrypt"
  [INTERNAL_WEBROOT_DIR]="/usr/share/nginx/html"
  [INTERNAL_CERTS_DH_DIR]="/etc/ssl/certs/dhparam"
)

# SSL Certificate Paths
declare -A SSL_PATHS=(
  [PRIVKEY_PATH]="${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/privkey.pem"
  [FULLCHAIN_PATH]="${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/fullchain.pem"
  [DH_PARAMS_PATH]="${INTERNAL_DIRS[INTERNAL_CERTS_DH_DIR]}/dhparam-2048.pem"
)

# Docker Volume Mappings for Nginx
declare -A NGINX_VOLUME_MAPPINGS=(
  [CERTS_VOLUME_MAPPING]="${DIRS[CERTS_DIR]}:${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_DIR]}"
  [DH_VOLUME_MAPPING]="${DIRS[CERTS_DH_DIR]}:${INTERNAL_DIRS[INTERNAL_CERTS_DH_DIR]}"
)

# Docker Volume Mappings for Certbot
declare -A CERTBOT_VOLUME_MAPPINGS=(
  [LETS_ENCRYPT_VOLUME_MAPPING]="${DIRS[CERTS_DIR]}:${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_DIR]}"
  [LETS_ENCRYPT_LOGS_VOLUME_MAPPING]="${DIRS[WEBROOT_DIR]}/logs:${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_LOGS_DIR]}"
  [CERTS_DH_VOLUME_MAPPING]="${DIRS[CERTS_DH_DIR]}:${INTERNAL_DIRS[INTERNAL_CERTS_DH_DIR]}"
  [WEBROOT_VOLUME_MAPPING]="${DIRS[WEBROOT_DIR]}:${INTERNAL_DIRS[INTERNAL_WEBROOT_DIR]}"
)

update_ssl_paths() {
  SSL_PATHS[PRIVKEY_PATH]="${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/privkey.pem"
  SSL_PATHS[FULLCHAIN_PATH]="${INTERNAL_DIRS[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/fullchain.pem"
  SSL_PATHS[DH_PARAMS_PATH]="${INTERNAL_DIRS[INTERNAL_CERTS_DH_DIR]}/dhparam-2048.pem"
}

handle_missing_certificates() {
  update_ssl_paths

  # Check for missing certificates
  if [[ ! -f "${SSL_PATHS[PRIVKEY_PATH]}" ]] || [[ ! -f "${SSL_PATHS[FULLCHAIN_PATH]}" ]]; then
    echo "Error: Missing certificates."
    generate_default_certificates
  fi
}

generate_default_certificates() {
  local certs_dir="${DIRS[CERTS_DIR]}"
  local certs_dh_dir="${DIRS[CERTS_DH_DIR]}"

  echo "Generating self-signed certificates for ${DOMAIN_NAME}..."

  local certs_path=${certs_dir}/live/${DOMAIN_NAME}

  # Ensure the necessary directories exist
  create_directory "${certs_path}"
  create_directory "${certs_dh_dir}"

  # Check and generate new self-signed certificates if needed
  if [[ ! -f "${certs_path}/fullchain.pem" ]] || prompt_for_regeneration "${certs_path}"; then
    # Create self-signed certificate and private key
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
      -keyout "${certs_path}/privkey.pem" \
      -out "${certs_path}/fullchain.pem" \
      -subj "/CN=${DOMAIN_NAME}"

    echo "Self-signed certificates for ${DOMAIN_NAME} generated at ${certs_path}."
  else
    echo "Certificates for ${DOMAIN_NAME} already exist at ${certs_path}."
  fi

  local dh_params_path="${certs_dh_dir}/dhparam-2048.pem"
  # Generate DH parameters if they don't exist
  if [[ ! -f "${dh_params_path}" ]]; then
    # Generate the DH parameters
    openssl dhparam -out "${dh_params_path}" 2048
    echo "DH parameters generated at ${dh_params_path}."
  else
    echo "DH parameters already exist at ${dh_params_path}."
  fi
}

configure_nginx() {
  echo "Creating NGINX configuration..."

  # Define local variables for the configuration
  local backend_scheme="http"
  local ssl_config=""
  local token_directive=""
  local server_name="${DOMAIN_NAME}"
  local listen_directive="listen $NGINX_PORT;
        listen [::]:$NGINX_PORT;"
  local ssl_listen_directive=""
  local acme_challenge_server_block=""

  # Handle subdomain configuration if necessary
  if [[ "$SUBDOMAIN" != "www" && -n "$SUBDOMAIN" ]]; then
    server_name="${SUBDOMAIN}.${DOMAIN_NAME}"
  fi

  # Update server_name_directive to include both domain and subdomain if using Let's Encrypt
  local server_name_directive="server_name ${server_name};"

  # Handle Let's Encrypt configuration
  if [[ "$USE_LETS_ENCRYPT" == "yes" ]]; then
    backend_scheme="https"
    token_directive="server_tokens off;"
    server_name_directive="server_name ${DOMAIN_NAME} ${SUBDOMAIN}.${DOMAIN_NAME};"
    ssl_listen_directive="listen $NGINX_SSL_PORT ssl;
        listen [::]:$NGINX_SSL_PORT ssl;"

    handle_missing_certificates

    # Bind the SSL paths updated in handle_missing_certificates
    local FULLCHAIN_PATH="${SSL_PATHS[FULLCHAIN_PATH]}"
    local PRIVKEY_PATH="${SSL_PATHS[PRIVKEY_PATH]}"

    # Configure the SSL settings
    ssl_config="
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;
        ssl_ciphers 'ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5';
        ssl_buffer_size 8k;
        ssl_dhparam ${SSL_PATHS[DH_PARAMS_PATH]};
        ssl_ecdh_curve secp384r1;
        ssl_session_tickets off;
        ssl_stapling on;
        ssl_stapling_verify on;

        resolver ${DNS_RESOLVER} valid=300s;
        resolver_timeout ${TIMEOUT};

        ssl_certificate ${FULLCHAIN_PATH};
        ssl_certificate_key ${PRIVKEY_PATH};
        ssl_trusted_certificate ${FULLCHAIN_PATH};"

    acme_challenge_server_block="server {
        listen 80;
        listen [::]:80;
        server_name ${server_name};

        location / {
            return 301 https://\$host\$request_uri;
        }

        location /.well-known/acme-challenge/ {
            allow all;
            root /usr/share/nginx/html;
        }
    }"

  fi

  # Backup existing configuration
  if [[ -f "${PROJECT_ROOT_DIR}/nginx.conf" ]]; then
    cp "${PROJECT_ROOT_DIR}/nginx.conf" "${PROJECT_ROOT_DIR}/nginx.conf.bak"
    echo "Backup created at ${PROJECT_ROOT_DIR}/nginx.conf.bak"
  fi

  # Write the final configuration
  cat <<-EOF >"${PROJECT_ROOT_DIR}/nginx.conf"
worker_processes auto;
events {
    worker_connections 1024;
}
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        ${listen_directive}
        ${ssl_listen_directive}
        ${token_directive}
        ${server_name_directive}
        ${ssl_config}

        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
            try_files \$uri \$uri/ /index.html;
            # Security headers
            add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
            add_header X-Frame-Options "DENY" always;
            add_header X-Content-Type-Options nosniff always;
            add_header X-XSS-Protection "1; mode=block" always;
            add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        }

        location /qr/ {
            proxy_pass ${backend_scheme}://backend:${BACKEND_PORT};
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
    $acme_challenge_server_block
 }
EOF

  # Check for errors in writing the configuration
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to write NGINX configuration."
    return 1
  fi

  cat "${PROJECT_ROOT_DIR}/nginx.conf"
  # Output the result
  echo "NGINX configuration written to ${PROJECT_ROOT_DIR}/nginx.conf"
}

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
    certbot_command="certonly --webroot --webroot-path=${INTERNAL_DIRS[INTERNAL_WEBROOT_DIR]} ${STAGING} ${WITHOUT_EMAIL} ${TOS} ${NO_EFF_EMAIL} ${KEEP_UNTIL_EXPIRY} ${FORCE_RENEWAL} ${RSA_KEY_SIZE_FLAG} --domains ${DOMAIN_NAME} --domains ${SUBDOMAIN}.${DOMAIN_NAME} --dry-run"

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

configure_frontend_docker() {
  cat <<EOF >"$FRONTEND_DIR/Dockerfile"
# Use the latest version of Node.js
FROM node:$NODE_VERSION as build

# Set the default working directory
WORKDIR /usr/app

# Install project dependencies
RUN npm init -y \
 && npm install react-leaflet leaflet react react-dom typescript \
 && npm install --save-dev vite jsdom vite-tsconfig-paths vite-plugin-svgr vitest \
 && npm install --save-dev @babel/plugin-proposal-private-property-in-object \
 && npm install --save-dev @vitejs/plugin-react @testing-library/react @testing-library/jest-dom \
 && npm install @types/leaflet @types/react @types/react-dom @types/jest\
 && npx create-vite frontend --template react-ts

# Delete the default App.tsx/App.css file (does not use kebab case)
RUN rm /usr/app/frontend/src/App.tsx
RUN rm /usr/app/frontend/src/App.css

# Copy Project files to the container
COPY frontend/src/ /usr/app/frontend/src
COPY frontend/public/ /usr/app/frontend/public
COPY frontend/tsconfig.json /usr/app/frontend
COPY frontend/index.html /usr/app/frontend

# Move to the frontend directory before building
WORKDIR /usr/app/frontend

# Build the project
RUN npm run build

# Install nginx
FROM nginx:alpine

# Copy the build files to the nginx directory
COPY --from=build /usr/app/frontend/dist /usr/share/nginx/html

# Create .well-known and .well-known/acme-challenge directories
RUN mkdir /usr/share/nginx/html/.well-known/
RUN mkdir /usr/share/nginx/html/.well-known/acme-challenge
RUN chmod -R 777 /usr/share/nginx/html/.well-known

# Set the nginx port
EXPOSE $NGINX_PORT

# Run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
EOF
}

configure_backend_docker() {
  cat <<EOF >"$BACKEND_DIR/Dockerfile"
# Use the latest version of Node.js
FROM node:$NODE_VERSION

# Set the default working directory
WORKDIR /usr/app

RUN npm install -g ts-node typescript \
 && npm install --save-dev typescript ts-node jest ts-jest jsdom \
 && npx tsc --init \
 && npm install dotenv express cors multer archiver express-rate-limit helmet qrcode \
 && npm install --save-dev @types/express @types/cors @types/node @types/multer @types/archiver \
 && npm install --save-dev @types/express-rate-limit @types/helmet @types/qrcode @types/jest \

COPY $BACKEND_FILES /usr/app

# Set the backend express port
EXPOSE $BACKEND_PORT

# Use ts-node to run the TypeScript server file
CMD ["npx", "ts-node", "src/server.ts"]
EOF
}

# ---- Main Function/Entry ---- #

# Sets up the directories, configures Docker in rootless mode
# Generates necessary configuration files, and runs the Docker setup.
main() {
  setup_project_directories
  setup_docker_rootless
  ensure_port_available "$NGINX_PORT"
  prompt_for_domain_and_letsencrypt
  generate_server_files
  configure_nginx
  build_and_run_docker
}

user_prompt
