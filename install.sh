#!/bin/bash
set -euo pipefail

# Change the current working directory to the script's location.
cd "$(dirname "$0")"

# Define project-related constants and directory paths.
readonly PROJECT_DIR="$HOME/QRGen-FullStack"
readonly BACKEND_DIR="$PROJECT_DIR/backend"
readonly FRONTEND_DIR="$PROJECT_DIR/frontend"
readonly SERVER_DIR="$PROJECT_DIR/saved_qrcodes"
readonly STAGING_DIR="$PROJECT_DIR/staging"

# Define Let's Encrypt-related constants and directory paths.
readonly LETS_ENCRYPT_BASE="$HOME/docker_letsencrypt"
readonly LETS_ENCRYPT_DIR="$LETS_ENCRYPT_BASE/etc/letsencrypt"
readonly LETS_ENCRYPT_LIB="$LETS_ENCRYPT_BASE/var/lib/letsencrypt"
readonly LETS_ENCRYPT_LOG="$LETS_ENCRYPT_BASE/var/log/letsencrypt"
readonly LETS_ENCRYPT_SITE="$LETS_ENCRYPT_BASE/docker/letsencrypt-docker-nginx/src/letsencrypt/letsencrypt-site"
readonly LETS_ENCRYPT_DH_PARAM="$LETS_ENCRYPT_BASE/docker/letsencrypt-docker-nginx/src/letsencrypt/dh-param"
readonly DH_PARAM_FILE="$LETS_ENCRYPT_DH_PARAM/dhparam-2048.pem"

# Define configuration-related constants.
BACKEND_PORT=3001
NGINX_PORT=8080
NODE_VERSION=20.8.0
DOMAIN_NAME=""
USE_LETS_ENCRYPT="no"
DOCKER_HOST=""

# Sets up the directories required for Let's Encrypt.
setup_letsencrypt_directories() {
  echo "Creating Let's Encrypt directories..."
  create_directory "$LETS_ENCRYPT_BASE"
  create_directory "$LETS_ENCRYPT_DIR"
  create_directory "$LETS_ENCRYPT_LIB"
  create_directory "$LETS_ENCRYPT_LOG"
  create_directory "$LETS_ENCRYPT_SITE"
  create_directory "$LETS_ENCRYPT_DH_PARAM"
  echo "Finished creating Let's Encrypt directories."
}

# Generates Diffie-Hellman parameters for Let's Encrypt.
generate_dhparam() {
  echo "Generating Diffie-Hellman parameters..."
  if [[ -d $LETS_ENCRYPT_DH_PARAM ]]; then
    openssl dhparam -out "$LETS_ENCRYPT_DH_PARAM/dhparam-2048.pem" 2048
  else
    echo "Error: Diffie-Hellman parameters directory $LETS_ENCRYPT_DH_PARAM does not exist."
    echo "Ensure that setup_letsencrypt_directories() is being run.. Exiting."
    exit 1
  fi

}

# Prompt for let's encrypt setup
prompt_for_letsencrypt() {
  read -rp "Do you want to setup Let's Encrypt SSL (yes/no)? " USE_LETS_ENCRYPT

  if [[ "$USE_LETS_ENCRYPT" == "yes" ]]; then
    read -rp "Enter your domain name (e.g., example.com): " DOMAIN_NAME
    if [[ $DOMAIN_NAME != "" ]]; then
      letsencrypt_setup
    else
      echo "Error: Domain name cannot be empty. Exiting."
      exit 1
    fi

  else
    DOMAIN_NAME="localhost"
  fi
}

# Sets up Let's Encrypt.
letsencrypt_setup() {
  if [[ "$USE_LETS_ENCRYPT" == "yes" ]]; then
    setup_letsencrypt_directories
    generate_dhparam
    get_certificates
  fi
}

# Obtains SSL certificates from Let's Encrypt.
get_certificates() {
  echo "Obtaining SSL certificates for $DOMAIN_NAME..."
  docker run -it --rm \
    -v "$LETS_ENCRYPT_DIR:/etc/letsencrypt" \
    -v "$LETS_ENCRYPT_LIB:/var/lib/letsencrypt" \
    -v "$LETS_ENCRYPT_SITE:/data/letsencrypt" \
    -v "$LETS_ENCRYPT_LOG:/var/log/letsencrypt" \
    certbot/certbot \
    certonly --webroot \
    --non-interactive \
    --register-unsafely-without-email \
    --agree-tos \
    --webroot-path=/data/letsencrypt \
    --staging \
    -d "$DOMAIN_NAME" -d www."$DOMAIN_NAME"
}

# Creates the specified directory if it does not already exist.
create_directory() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo "$1 created."
  else
    echo "$1 already exists."
  fi
}

# Copies the server files to the staging directory.
copy_server_files() {
  echo "Copying server files..."
  cp -r "src" "$STAGING_DIR"
  cp -r "public" "$STAGING_DIR"
  cp "tsconfig.json" "$STAGING_DIR"
  cp "index.html" "$STAGING_DIR"
  cp -r "server" "$BACKEND_DIR"
}

# Sets up the project directories.
setup_project_directories() {
  echo "Staging project directories..."

  # Ensure required directories exist.
  create_directory "$SERVER_DIR"
  create_directory "$FRONTEND_DIR"
  create_directory "$BACKEND_DIR"
  create_directory "$STAGING_DIR"

  local SRC_DIR="$HOME/QRGen-FullStack/src"

  if [[ -d "$SRC_DIR" ]]; then
    copy_server_files
  else
    echo "Error: Source directory $SRC_DIR does not exist. Attempting to create.."
    # Create the source directory if possible, otherwise exit with an error.
    if ! mkdir -p "$SRC_DIR"; then
      echo "Error: Failed to create source directory $SRC_DIR"
      exit 1
    else
      echo "Source directory $SRC_DIR created."
      copy_server_files
    fi
  fi
}

# Ensures XDG_RUNTIME_DIR is set.
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

# Validates and sets Docker-related environment variables.
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

# Uses Docker Compose to build and launch the Docker containers for the project.
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

# Writes the NGINX configuration file to the project directory.
create_nginx_configuration() {
  echo "Creating NGINX configuration..."
  # Default configurations
  local backend_scheme="http"
  local ssl_config=""
  local listen_directive="listen $NGINX_PORT;"
  local letsencrypt_challenge=""
  local token_directive=""
  local server_name_directive="server_name $DOMAIN_NAME;"

  # LetsEncrypt-specific configurations
  if [[ "$USE_LETS_ENCRYPT" == "yes" ]]; then
    backend_scheme="https"
    read -r -d '' ssl_config <<EOL
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
    # SSL configurations
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
write_frontend_docker() {
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
COPY staging/src/ /usr/app/frontend/src
COPY staging/public/ /usr/app/frontend/public
COPY staging/tsconfig.json /usr/app/frontend
COPY staging/index.html /usr/app/frontend

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
write_backend_docker() {
  cat <<EOF >"$BACKEND_DIR/Dockerfile"
# Use the latest version of Node.js
FROM node:$NODE_VERSION

# Set the default working directory
WORKDIR /usr/app

RUN npm install -g ts-node typescript \
 && npm install --save-dev typescript ts-node jest ts-jest dompurify jsdom \
 && npx tsc --init \
 && npm install --save express cors multer archiver express-rate-limit helmet qrcode \
 && npm install --save-dev @types/express @types/cors @types/node @types/multer @types/archiver \
 && npm install --save-dev @types/express-rate-limit @types/helmet @types/qrcode @types/jest @types/dompurify \

# Copy Project files to the container
COPY backend/server/ /usr/app
COPY backend/tsconfig.json /usr/app

# Set the backend express port
EXPOSE $BACKEND_PORT

# Use ts-node to run the TypeScript server file
CMD ["npx", "ts-node", "src/server.ts"]
EOF
}

# Writes the TypeScript configuration file to the backend directory.
write_tsconfig() {
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

# Writes the Docker Compose file to the project directory.
write_docker_compose() {
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
create_server_configuration_files() {
  echo "Creating server configuration files..."
  write_tsconfig
  echo "Configuring the Docker Express backend..."
  write_backend_docker
  echo "Configuring the Docker NGINX Proxy & frontend..."
  write_frontend_docker
  echo "Configuring Docker Compose..."
  write_docker_compose
}

# Dumps logs of all containers orchestrated by the Docker Compose file.
dump_logs() {
  ensure_docker_env
  echo "Dumping Docker logs..."
  if [[ -f "$PROJECT_DIR/docker-compose.yml" ]]; then
    docker compose -f "$PROJECT_DIR/docker-compose.yml" logs >"$PROJECT_DIR/docker_logs_$(date +"%Y%m%d_%H%M%S").txt"
    echo "Logs dumped to $PROJECT_DIR/docker_logs_$(date +"%Y%m%d_%H%M%S").txt"
    echo "Contents:"
    cat "$PROJECT_DIR/docker_logs_$(date +"%Y%m%d_%H%M%S").txt"
    echo "Done."
  else
    echo "Error: Docker Compose configuration not found!"
  fi
}

# Cleans current Docker Compose setup, arranges directories, and reinitiates Docker services.
reload_project() {
  echo "Reloading the project..."
  ensure_docker_env
  setup_project_directories
  if [[ -f "$PROJECT_DIR/docker-compose.yml" ]]; then
    docker compose -f "$PROJECT_DIR/docker-compose.yml" down
  fi
  create_server_configuration_files
  create_nginx_configuration
  build_and_run_docker
  dump_logs
}

# Shuts down any running Docker containers associated with the project and deletes the entire project directory.
cleanup() {
  ensure_docker_env
  echo "Cleaning up..."
  if [[ -f "$PROJECT_DIR/docker-compose.yml" ]]; then
    docker compose -f "$PROJECT_DIR/docker-compose.yml" down
    docker system prune -a -f
    echo "Docker containers cleaned up."
  fi
  if [[ -d "$PROJECT_DIR" ]]; then
    rm -rf "$PROJECT_DIR"
    echo "Project directory $PROJECT_DIR deleted."
  fi
  if [[ -d "$STAGING_DIR" ]]; then
    rm -rf "$STAGING_DIR"
    echo "Staging directory $STAGING_DIR deleted."
  fi
}

# Sets up the directories, configures Docker in rootless mode
# Generates necessary configuration files, and runs the Docker setup.
main() {
  setup_project_directories
  setup_docker_rootless
  prompt_for_letsencrypt
  create_server_configuration_files
  create_nginx_configuration
  build_and_run_docker
}

# Users choose between setting up the project, cleaning up, reloading the project, or dumping Docker logs.
user_prompt() {
  echo "Welcome to the QR Code Generator setup script!"

  PS3="Choose an option (1/2/3/4): "
  local options=("Run Setup" "Cleanup" "Reload/Refresh" "Dump Docker Logs")
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
    "Dump Docker Logs")
      dump_logs
      break
      ;;
    *)
      echo "Invalid option"
      ;;
    esac
  done
}

# Serves as the entry point to the script.
user_prompt
