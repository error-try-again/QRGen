#!/bin/bash

set -euo pipefail

# Ensure we're in the project directory of the script
cd "$(dirname "$0")"

# Constants
readonly PROJECT_DIR="$HOME/qr-code-generator"
readonly BACKEND_DIR="$PROJECT_DIR/backend"
readonly FRONTEND_DIR="$PROJECT_DIR/frontend"
readonly SERVER_DIR="$PROJECT_DIR/saved_qrcodes"
readonly STAGING_DIR="$PROJECT_DIR/staging"
BACKEND_PORT=3001
NGINX_PORT=8080
NODE_VERSION=20.8.0

# Directory Setup Functions
create_directory() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo "$1 created."
  fi
}

setup_project_directories() {

  echo "Staging project directories..."

  # Check and create directories using the function
  create_directory "$SERVER_DIR"
  create_directory "$FRONTEND_DIR"
  create_directory "$BACKEND_DIR"
  create_directory "$STAGING_DIR"

  # Using a fixed path for the src directory
  local SRC_DIR="/home/void/Desktop/fullstack-qr-generator/src"

  # Check if the source directory exists before attempting to copy
  if [[ -d "$SRC_DIR" ]]; then
    cp -r "$SRC_DIR" "$STAGING_DIR"
    cp "tsconfig.json" "$STAGING_DIR"
    cp "index.html" "$STAGING_DIR"
  else
    echo "Error: Source directory $SRC_DIR does not exist!"
    exit 1
  fi

  # Copy all the backend files from src to tmp
  cp -r "server" "$BACKEND_DIR"
}

setup_docker_rootless() {

  # Function to add a line to ~/.bashrc if it doesn't exist
  add_to_bashrc() {
    local line="$1"
    if ! grep -q "^${line}$" ~/.bashrc; then
      echo "$line" >>~/.bashrc
    fi
  }

  echo "Setting up Docker in rootless mode..."

  # Check for Docker
  if ! command -v docker &>/dev/null; then
    echo "Docker is not installed. Please install Docker to continue."
    exit 1
  fi

  # Check if dockerd-rootless-setuptool.sh exists before running it
  if ! command -v dockerd-rootless-setuptool.sh >/dev/null 2>&1; then
    echo "dockerd-rootless-setuptool.sh not found. Exiting."
    return 1
  else
    dockerd-rootless-setuptool.sh install
  fi

  local XDG_RUNTIME_DIR
  local DOCKER_HOST

  XDG_RUNTIME_DIR=/run/user/$(id -u)
  DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock

  export PATH=/usr/bin:$PATH
  export XDG_RUNTIME_DIR
  export DOCKER_HOST

  add_to_bashrc "export PATH=/usr/bin:$PATH"
  add_to_bashrc "export XDG_RUNTIME_DIR=/run/user/$(id -u)"
  add_to_bashrc "DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock"

  systemctl --user status docker.service
  systemctl --user start docker.service
  systemctl --user enable docker.service

}

build_and_run_docker() {
  echo "Building and running Docker setup..."
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

create_nginx_configuration() {
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

    server {
        listen $NGINX_PORT;
        server_name localhost;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
            try_files \$uri \$uri/ /index.html;
        }

        location /qr/generate {
            proxy_pass http://backend:$BACKEND_PORT;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }

        location /qr/batch {
            proxy_pass http://backend:$BACKEND_PORT;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
}
EOF
}

create_server_configuration_files() {
  echo "Setting up the backend..."

  cat <<EOF >"$BACKEND_DIR/tsconfig.json"
{
  "compilerOptions": {
    "target": "ES2021",  // Use latest ECMAScript features
    "module": "CommonJS",  // Use latest ECMAScript features
    "lib": ["ES2021"],  // Target ECMAScript features
    "outDir": "./dist",  // Output directory for compiled JS files
    "rootDir": "./src",  // Root directory containing TS source files
    "strict": true,  // Enable all strict type-checking options
    "moduleResolution": "node",  // Use Node.js module resolution strategy
    "skipLibCheck": true,  // Skip type checking of declaration files
    "esModuleInterop": true,  // Enables CommonJS/AMD/UMD module emit interop
    "resolveJsonModule": true,  // Include modules imported with .json extension
    "isolatedModules": true,  // Ensure each file can be safely transpiled without considering other modules
    "noEmitOnError": true,  // Do not emit outputs if any errors were reported
    "forceConsistentCasingInFileNames": true,  // Disallow inconsistent casing in filenames
    "noUnusedLocals": true,  // Report errors on unused locals
    "noUnusedParameters": true,  // Report errors on unused parameters
    "noImplicitReturns": true,  // Report error when not all code paths in function return a value
    "noFallthroughCasesInSwitch": true  // Report errors for fallthrough cases in switch statement
  },
  "include": ["src/**/*.ts"],  // Source files to be compiled
}
EOF

  cat <<EOF >"$BACKEND_DIR/Dockerfile"
# Use the latest version of Node.js
FROM node:$NODE_VERSION

# Set the default working directory
WORKDIR /usr/app

RUN npm install -g ts-node typescript \
 && npm install --save-dev @types/node typescript ts-node jest ts-jest \
 && npx tsc --init \
 && npm install --save express cors multer archiver express-rate-limit helmet qrcode \
 && npm install --save-dev @types/express @types/cors @types/node @types/multer @types/archiver @types/express-rate-limit @types/helmet @types/qrcode @types/jest

# Copy Project files to the container
COPY backend/server/ /usr/app
COPY backend/tsconfig.json /usr/app

# Set the backend express port
EXPOSE $BACKEND_PORT

# Use ts-node to run the TypeScript server file
CMD ["npx", "ts-node", "src/server.ts"]
EOF

  cat <<EOF >"$FRONTEND_DIR/Dockerfile"
# Use the latest version of Node.js
FROM node:$NODE_VERSION as build

# Set the default working directory
WORKDIR /usr/app

# Install project dependencies
RUN npm init -y \
 && npm install react-leaflet leaflet @types/leaflet react react-dom typescript \
 && npm install --save-dev @babel/plugin-proposal-private-property-in-object vite @vitejs/plugin-react vite-tsconfig-paths vite-plugin-svgr @types/react @types/react-dom \
 && npx create-vite frontend --template react-ts

# Delete the default App.tsx/App.css file (does not use kebab case)
RUN rm /usr/app/frontend/src/App.tsx
RUN rm /usr/app/frontend/src/App.css

# Copy Project files to the container
COPY staging/src/ /usr/app/frontend/src
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
  nginx:
    build:
      context: .
      dockerfile: ./frontend/Dockerfile
    ports:
      - "${NGINX_PORT}:${NGINX_PORT}"
    volumes:
     - ./frontend:/usr/app
     - ./nginx.conf:/etc/nginx/nginx.conf
     - ./saved_qrcodes:/usr/share/nginx/html/saved_qrcodes
EOF
}

# Project Operations
reload_project() {
  echo "Reloading the project..."
  setup_project_directories
  if [[ -f "$PROJECT_DIR/docker-compose.yml" ]]; then
    docker compose -f "$PROJECT_DIR/docker-compose.yml" down
  fi
  create_server_configuration_files
  create_nginx_configuration
  build_and_run_docker
}

cleanup() {
  echo "Cleaning up..."
  if [[ -f "$PROJECT_DIR/docker-compose.yml" ]]; then
    docker compose -f "$PROJECT_DIR/docker-compose.yml" down
  fi
  if [[ -d "$PROJECT_DIR" ]]; then
    rm -rf "$PROJECT_DIR"
  fi
}

# Main Execution Flow
main() {
  setup_project_directories
  setup_docker_rootless
  create_server_configuration_files
  create_nginx_configuration
  build_and_run_docker
}

user_prompt() {
  echo "Welcome to the QR Code Generator setup script!"

  PS3="Choose an option (1/2/3): "
  local options=("Run Setup" "Cleanup" "Reload/Refresh")
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
    *)
      echo "Invalid option"
      ;;
    esac
  done
}

USER_ARG=$1

user_prompt
