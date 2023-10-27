#!/bin/bash
set -euo pipefail

# Change the current working directory to the script's location.
cd "$(dirname "$0")"

# Define constants and directory paths.
declare -r PROJECT_DIR="$HOME/QRGen-FullStack"
declare -r BACKEND_DIR="$PROJECT_DIR/backend"
declare -r FRONTEND_DIR="$PROJECT_DIR/frontend"
declare -r SERVER_DIR="$PROJECT_DIR/saved_qrcodes"

declare -r LETS_ENCRYPT_BASE="$HOME/docker_letsencrypt"
declare -r LETS_ENCRYPT_DIR="$LETS_ENCRYPT_BASE/etc/letsencrypt"
declare -r LETS_ENCRYPT_LIB="$LETS_ENCRYPT_BASE/var/lib/letsencrypt"
declare -r LETS_ENCRYPT_LOG="$LETS_ENCRYPT_BASE/var/log/letsencrypt"
declare -r LETS_ENCRYPT_SITE="$LETS_ENCRYPT_BASE/docker/letsencrypt-docker-nginx/src/letsencrypt/letsencrypt-site"
declare -r LETS_ENCRYPT_DH_PARAM="$LETS_ENCRYPT_BASE/docker/letsencrypt-docker-nginx/src/letsencrypt/dh-param"
declare -r DH_PARAM_FILE="$LETS_ENCRYPT_DH_PARAM/dhparam-2048.pem"

# Configuration-related constants.
BACKEND_PORT=3001
NGINX_PORT=8080
BACKEND_SCHEME="http"
DOMAIN_NAME="localhost"
ORIGIN_URL="$BACKEND_SCHEME://$DOMAIN_NAME"
ORIGIN_PORT="$NGINX_PORT"
ORIGIN="$ORIGIN_URL:$ORIGIN_PORT"
NODE_VERSION="20.8.0"
SUBDOMAIN="www"
USE_LETS_ENCRYPT="no"
DOCKER_HOST=""
BACKEND_FILES=""

# ---- Helper Functions ---- #

create_directory() {
  local directory="$1"
  if [ ! -d "$directory" ]; then
    mkdir -p "$directory"
    echo "$directory created."
  else
    echo "$directory already exists."
  fi
}

docker_compose_exists() {
  [[ -f "$PROJECT_DIR/docker-compose.yml" ]]
}

copy_server_files() {
  echo "Copying server files..."
  copy_frontend_files
  copy_backend_files
}

copy_backend_files() {
  echo "Copying backend files..."
  cp -r "server" "$BACKEND_DIR"
  cp "tsconfig.json" "$BACKEND_DIR"
  cp ".env" "$BACKEND_DIR"
  BACKEND_FILES="backend/*"
}

copy_frontend_files() {
  ls "$PROJECT_DIR"
  echo "Copying frontend files..."
  cp -r "src" "$FRONTEND_DIR"
  cp -r "public" "$FRONTEND_DIR"
  cp "tsconfig.json" "$FRONTEND_DIR"
  cp "index.html" "$FRONTEND_DIR"
}

ensure_xdg_runtime() {
  echo "Ensuring XDG_RUNTIME_DIR is set..."
  local XDG_RUNTIME_DIR
  # Update or set XDG_RUNTIME_DIR.
  if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ "${XDG_RUNTIME_DIR:-}" != "/run/user/$(id -u)" ]; then
    XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export XDG_RUNTIME_DIR
    echo "Set XDG_RUNTIME_DIR to ${XDG_RUNTIME_DIR}"
  fi
}

ensure_docker_env() {
  echo "Ensuring Docker environment variables are set..."
  local expected_docker_host
  # Update or set DOCKER_HOST.
  expected_docker_host="unix:///run/user/$(id -u)/docker.sock"
  if [ -z "${DOCKER_HOST:-}" ] || [ "${DOCKER_HOST:-}" != "${expected_docker_host}" ]; then
    DOCKER_HOST="${expected_docker_host}"
    export DOCKER_HOST
    echo "Set DOCKER_HOST to ${DOCKER_HOST}"
  fi
}

bring_down_docker_compose() {
  if docker_compose_exists; then
    docker compose -f "$PROJECT_DIR/docker-compose.yml" down
  fi
}

produce_docker_logs() {
  if docker_compose_exists; then
    docker compose -f "$PROJECT_DIR/docker-compose.yml" logs
  fi
}

is_port_in_use() {
  local port="$1"
  if lsof -i :"$port" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

ensure_port_available() {
  local port="$1"
  if is_port_in_use "$port"; then
    echo "Port $port is already in use."
    read -rp "Please provide an alternate port or Ctrl+C to exit: " port
    port="${port:-$default_port}"
  fi
  NGINX_PORT="$port"
}

# Prompts user with a message and ensures a non-empty response.
# Returns the response when it's non-empty.
prompt_with_validation() {
  local prompt_message="$1"
  local error_message="$2"
  local user_input=""

  while true; do
    read -rp "$prompt_message" user_input

    if [[ -z "$user_input" ]]; then
      echo "$error_message"
    else
      echo "$user_input"
      break
    fi
  done
}

# ---- Setup Functions ---- #

setup_project_directories() {
  echo "Staging project directories..."

  local directory
  for directory in "$SERVER_DIR" "$FRONTEND_DIR" "$BACKEND_DIR"; do
    create_directory "$directory"
  done

  local SRC_DIR="$HOME/QRGen-FullStack/src"

  if [[ -d "$SRC_DIR" ]]; then
    copy_server_files
  else
    echo "Error: $SRC_DIR does not exist. Attempting to create."

    if mkdir -p "$SRC_DIR"; then
      echo "Source directory $SRC_DIR created."
      copy_server_files
    else
      echo "Error: Failed to create $SRC_DIR"
      exit 1
    fi
  fi
}

# Configures Docker to operate in rootless mode, updating user's bashrc as required.
setup_docker_rootless() {
  echo "Setting up Docker in rootless mode..."

  # Validate Docker installation.
  if ! command -v docker &>/dev/null; then
    echo "Docker is not installed. Please install Docker to continue."
    exit 1
  fi

  # Ensure rootless setup tool is available before attempting setup.
  if ! command -v dockerd-rootless-setuptool.sh >/dev/null 2>&1; then
    echo "dockerd-rootless-setuptool.sh not found. Exiting."
    return 1
  else
    dockerd-rootless-setuptool.sh install
  fi

  # Ensure Docker environment variables are set.
  ensure_docker_env

  # Append environment settings to the user's bashrc.
  add_to_bashrc() {
    local line="$1"
    if ! grep -q "^${line}$" ~/.bashrc; then
      echo "$line" >>~/.bashrc
    fi
  }

  add_to_bashrc "export PATH=/usr/bin:$PATH"
  add_to_bashrc "export XDG_RUNTIME_DIR=/run/user/$(id -u)"
  add_to_bashrc "DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock"

  # Manage Docker's systemd services.
  systemctl --user status docker.service
  systemctl --user start docker.service
  systemctl --user enable docker.service
}

setup_letsencrypt_directories() {
  echo "Creating Let's Encrypt directories..."
  local directories
  for directories in "$LETS_ENCRYPT_BASE" "$LETS_ENCRYPT_DIR" "$LETS_ENCRYPT_LIB" "$LETS_ENCRYPT_LOG" "$LETS_ENCRYPT_SITE" "$LETS_ENCRYPT_DH_PARAM"; do
    create_directory "$directories"
  done
  echo "Finished creating Let's Encrypt directories."
}

# ---- Let's Encrypt Functions ---- #

generate_dhparam() {
  echo "Generating Diffie-Hellman parameters..."

  if [[ -d $LETS_ENCRYPT_DH_PARAM ]]; then
    openssl dhparam -out "$DH_PARAM_FILE" 2048
  else
    echo "Error: $LETS_ENCRYPT_DH_PARAM does not exist. Ensure setup_letsencrypt_directories() is run."
    exit 1
  fi
}

letsencrypt_setup() {
  [[ "$USE_LETS_ENCRYPT" == "yes" ]] && setup_letsencrypt_directories && generate_dhparam && get_certificates
}

get_certificates() {
  echo "Obtaining SSL certificates for $DOMAIN_NAME..."
  docker run -it --rm \
    -v "$LETS_ENCRYPT_DIR:/etc/letsencrypt" \
    -v "$LETS_ENCRYPT_LIB:/var/lib/letsencrypt" \
    -v "$LETS_ENCRYPT_SITE:/data/letsencrypt" \
    -v "$LETS_ENCRYPT_LOG:/var/log/letsencrypt" \
    certbot/certbot \
    certonly --webroot --non-interactive --register-unsafely-without-email --agree-tos --webroot-path=/data/letsencrypt --staging -d "$DOMAIN_NAME" -d "$SUBDOMAIN"."$DOMAIN_NAME"
}

# ---- User Input ---- #

# Prompts the user for domain details and Let's Encrypt setup.
prompt_for_domain_and_letsencrypt() {
  local user_response=""
  local custom_domain_prompt="Would you like to specify a domain name other than the default (http://localhost) (yes/no)? "

  local domain_prompt="Enter your domain name (e.g., example.com): "
  local domain_error_message="Error: Domain name cannot be empty."

  local custom_subdomain_prompt="Would you like to specify a subdomain (e.g., www.example.com, void.example.com) other than the default (none) (yes/no)? "
  local subdomain_prompt="Enter your subdomain name (e.g., www): "
  local subdomain_error_message="Error: Subdomain name cannot be empty."

  # Ask if the user wants to specify a different domain name.
  read -rp "$custom_domain_prompt" user_response

  if [[ "$user_response" == "yes" ]]; then
    DOMAIN_NAME=$(prompt_with_validation "$domain_prompt" "$domain_error_message")
    ORIGIN_URL="$BACKEND_SCHEME://$DOMAIN_NAME"
    ORIGIN="$ORIGIN_URL:$ORIGIN_PORT"
    echo "Using custom domain name: $ORIGIN_URL"

    # Ask if the user wants to specify a subdomain.
    read -rp "$custom_subdomain_prompt" user_response

    if [[ "$user_response" == "yes" ]]; then
      SUBDOMAIN=$(prompt_with_validation "$subdomain_prompt" "$subdomain_error_message")
      ORIGIN_URL="$BACKEND_SCHEME://$SUBDOMAIN.$DOMAIN_NAME"
      ORIGIN="$ORIGIN_URL:$ORIGIN_PORT"
      echo "Using custom domain name: $ORIGIN_URL"
    fi

    local setup_letsencrypt_prompt="Would you like to setup Let's Encrypt SSL for $DOMAIN_NAME (yes/no)? "

    # Ask if the user wants to set up Let's Encrypt SSL.
    read -rp "$setup_letsencrypt_prompt" user_response

    if [[ "$USE_LETS_ENCRYPT" == "yes" ]]; then
      letsencrypt_setup
    fi
  else
    echo "Using default domain name: $DOMAIN_NAME"
  fi
}

# ---- Configuration Functions ---- #

# Writes the NGINX configuration file to the project directory.
configure_nginx() {
  echo "Creating NGINX configuration..."
  # Default configurations
  local backend_scheme="http"
  local ssl_config=""
  local listen_directive="listen $NGINX_PORT;"
  local letsencrypt_challenge=""
  local token_directive=""
  local server_name_directive="server_name $DOMAIN_NAME;"

  # if subdomain is not specified, use the domain name
  if [[ "$SUBDOMAIN" == "www" ]]; then
    server_name_directive="server_name $DOMAIN_NAME;"
  else
    server_name_directive="server_name $DOMAIN_NAME $SUBDOMAIN.$DOMAIN_NAME;"
  fi

  # LetsEncrypt-specific configurations
  if [[ "$USE_LETS_ENCRYPT" == "yes" ]]; then
    backend_scheme="https"
    read -r -d '' ssl_config <<EOL
    # SSL configurations
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5;
    ssl_buffer_size 8k;
    ssl_dhparam $DH_PARAM_FILE;
    ssl_ecdh_curve secp384r1;
    ssl_session_tickets off;
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8;

    ssl_certificate /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem;
EOL
    token_directive="server_tokens off;"
    listen_directive="listen $NGINX_PORT; listen [::]:$NGINX_PORT; listen 443 ssl;"
    letsencrypt_challenge="location ~ /.well-known/acme-challenge { allow all; root /usr/share/nginx/html; }"
    server_name_directive="server_name $DOMAIN_NAME www.$DOMAIN_NAME;"
  fi

  # Write configurations to nginx.conf
  cat <<EOF >"$PROJECT_DIR/nginx.conf"
worker_processes 1;
events {
    worker_connections 1024;
}
http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;
    log_format main '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                '\$status \$body_bytes_sent "\$http_referer" '
                '"\$http_user_agent" "\$http_x_forwarded_for"';
    access_log /var/log/nginx/access.log main;
    sendfile on;
    keepalive_timeout 65;
    $ssl_config
    server {
        $listen_directive
        $token_directive
        $server_name_directive
        $letsencrypt_challenge
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
            try_files \$uri \$uri/ /index.html;

            # Security headers
             add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";
             add_header X-XSS-Protection "1; mode=block" always;
             add_header X-Content-Type-Options "nosniff" always;
             add_header X-Frame-Options "DENY" always;

            # Content Security Policy
            # add_header Content-Security-Policy "frame-src 'self'; default-src 'self'; script-src 'self' 'unsafe-inline' https://maxcdn.bootstrapcdn.com https://ajax.googleapis.com; img-src 'self'; style-src 'self' https://maxcdn.bootstrapcdn.com; font-src 'self' data: https://maxcdn.bootstrapcdn.com; form-action 'self'; upgrade-insecure-requests;" always;
             add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        }
        location /qr/generate {
            proxy_pass $backend_scheme://backend:$BACKEND_PORT;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
        location /qr/batch {
            proxy_pass $backend_scheme://backend:$BACKEND_PORT;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}
EOF

  echo "nginx configuration written to $PROJECT_DIR/nginx.conf"
}

# Writes the Dockerfile to the frontend directory.
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

# Set the nginx port
EXPOSE $NGINX_PORT

# Run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
EOF
}

# Writes the Dockerfile to the backend directory.
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

# Writes the TypeScript configuration file to the backend directory.
configure_backend_tsconfig() {
  cat <<EOF >"$BACKEND_DIR/tsconfig.json"
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "CommonJS",
    "lib": ["ES2022"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "moduleResolution": "node",
    "skipLibCheck": true,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmitOnError": true,
    "forceConsistentCasingInFileNames": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  },
  "include": ["src/**/*.ts"],  // Source files to be compiled
}
EOF
}

configure_dot_env() {
  cat <<EOF >"$BACKEND_DIR/.env"
ORIGIN=$ORIGIN
PORT=$BACKEND_PORT
EOF
}

# Writes the Docker Compose file to the project directory.
configure_docker_compose() {
  local mount_extras=""
  local ssl_port=""
  local ssl_port_directive=""

  # LetsEncrypt-specific configurations
  if [[ "$USE_LETS_ENCRYPT" == "yes" ]]; then
    ssl_port="443"
    ssl_port_directive=" - \"${ssl_port}:${ssl_port}\""

    read -r -d '' mount_extras <<EOL
     - /docker-volumes/etc/letsencrypt/live/$DOMAIN_NAME:/etc/letsencrypt/live/$DOMAIN_NAME
     - /docker-volumes/etc/letsencrypt/archive/$DOMAIN_NAME:/etc/letsencrypt/archive/$DOMAIN_NAME
EOL
  fi

  cat <<EOF >"$PROJECT_DIR/docker-compose.yml"
version: '3.8'
services:
  backend:
    build:
      context: .
      dockerfile: ./backend/Dockerfile
    ports:
      - "${BACKEND_PORT}:${BACKEND_PORT}"
    volumes:
      - ./saved_qrcodes:/usr/app/saved_qrcodes
    networks:
      - qrgen
  frontend:
    build:
      context: .
      dockerfile: ./frontend/Dockerfile
    ports:
      - "${NGINX_PORT}:${NGINX_PORT}"
    $ssl_port_directive
    volumes:
     - ./frontend:/usr/app
     - ./nginx.conf:/etc/nginx/nginx.conf
     - ./saved_qrcodes:/usr/share/nginx/html/saved_qrcodes
    networks:
      - qrgen
$mount_extras
EOF

  # If Let's Encrypt is enabled, add the certbot service to the Docker Compose file
  if [[ "$USE_LETS_ENCRYPT" == "yes" ]]; then
    cat <<EOF >>"$PROJECT_DIR/docker-compose.yml"
  certbot:
    image: certbot/certbot
    command: certonly --webroot --webroot-path=/data/letsencrypt --email you@example.com --agree-tos --no-eff-email --staging
    volumes:
      - /docker-volumes/etc/letsencrypt:/etc/letsencrypt
      - /docker-volumes/var/lib/letsencrypt:/var/lib/letsencrypt
      - /docker/letsencrypt-docker-nginx/src/letsencrypt/letsencrypt-site:/data/letsencrypt
    depends_on:
      - frontend

networks:
  qrgen:
    driver: bridge
EOF
  else
    cat <<EOF >>"$PROJECT_DIR/docker-compose.yml"
networks:
  qrgen:
    driver: bridge
EOF
  fi
  echo "Docker Compose file written to $PROJECT_DIR/docker-compose.yml"
}

# Produces server-side configuration files essential for backend and frontend operations.
generate_server_files() {
  echo "Creating server configuration files..."
  configure_backend_tsconfig
  configure_dot_env
  echo "Configuring the Docker Express..."
  configure_backend_docker
  echo "Configuring the Docker NGINX Proxy..."
  configure_frontend_docker
  echo "Configuring Docker Compose..."
  configure_docker_compose
}

# --- User Actions --- #

# Dumps logs of all containers orchestrated by the Docker Compose file.
dump_logs() {
  ensure_docker_env

  local log_file
  log_file="$PROJECT_DIR/docker_logs_$(date +"%Y%m%d_%H%M%S").txt"

  produce_docker_logs >"$log_file" && {
    echo "Docker logs dumped to $log_file"
  }
}

# Cleans current Docker Compose setup, arranges directories, and reinitiates Docker services.
reload_project() {
  echo "Reloading the project..."
  ensure_docker_env
  setup_project_directories
  bring_down_docker_compose
  generate_server_files
  configure_nginx
  build_and_run_docker
  dump_logs
}

# Shuts down any running Docker containers associated with the project and deletes the entire project directory.
cleanup() {
  ensure_docker_env
  echo "Cleaning up..."

  bring_down_docker_compose

  declare -A directories=(
    ["Project"]=$PROJECT_DIR
    ["Frontend"]=$FRONTEND_DIR
    ["Backend"]=$BACKEND_DIR
    ["Let's Encrypt"]=$LETS_ENCRYPT_BASE
  )

  local dir_name
  local dir_path

  for dir_name in "${!directories[@]}"; do
    dir_path="${directories[$dir_name]}"
    if [[ -d "$dir_path" ]]; then
      rm -rf "$dir_path"
      echo "$dir_name directory $dir_path deleted."
    fi
  done

  echo "Cleanup complete."
}

update_project() {
  git pull
}

purge_builds() {
  echo "Purging Docker builds..."
  docker builder prune -a
}

quit() {
  echo "Exiting..."
  exit 0
}

# ---- Build and Run Docker ---- #

build_and_run_docker() {
  echo "Building and running Docker setup..."
  # Move to the project directory before invoking Docker commands.
  cd "$PROJECT_DIR" || {
    echo "Failed to change directory to $PROJECT_DIR"
    exit 1
  }
  docker compose build || {
    echo "Failed to build Docker image using Docker Compose"
    exit 1
  }
  docker compose up -d || {
    echo "Failed to run Docker Compose"
    exit 1
  }
  docker compose ps
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

# Users choose between setting up the project, cleaning up, reloading the project, or dumping Docker logs.
user_prompt() {
  echo "Welcome to the QR Code Generator setup script!"

  PS3="Choose an option (1/2/3/4/5/6/7): "
  local options=(
    "Run Setup"
    "Cleanup"
    "Reload/Refresh"
    "Update Project"
    "Dump Docker Logs"
    "Prune All Docker Builds - Dangerous"
    "Quit"
  )
  local opt

  select opt in "${options[@]}"; do
    case $opt in
    "Run Setup")
      main
      break
      ;;
    "Cleanup")
      cleanup
      break
      ;;
    "Reload/Refresh")
      reload_project
      break
      ;;
    "Update Project")
      update_project
      break
      ;;
    "Dump Docker Logs")
      dump_logs
      break
      ;;
    "Prune All Docker Builds - Dangerous")
      purge_builds
      break
      ;;
    "Quit")
      quit
      ;;
    *)
      echo "Invalid option"
      ;;
    esac
  done
}

# Serves as the entry point to the script.
user_prompt
