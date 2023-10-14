#!/bin/bash

set -euo pipefail

# Constants
readonly PROJECT_DIR="$HOME/qr-code-generator"
readonly FIRST_RUN_FILE="$PROJECT_DIR/.first_run"
readonly BACKEND_DIR="$PROJECT_DIR/backend"
readonly FRONTEND_DIR="$PROJECT_DIR/frontend"
readonly SOURCE_DIR="$FRONTEND_DIR/src"
readonly SERVER_DIR="$PROJECT_DIR/saved_qrcodes"
readonly DOCKER_DIR="/home/docker-primary"
readonly DEFAULT_NVM_DIR="$HOME/.nvm"
readonly STAGING_DIR="$PROJECT_DIR/staging"
readonly NODE_VERSION="20.8.0"

NVM_VERSION="v0.39.5"
BACKEND_PORT=3001
NGINX_PORT=8080

is_first_run() {
  if [ ! -e "$FIRST_RUN_FILE" ]; then
    touch "$FIRST_RUN_FILE"
    return 0
  else
    return 1 >/dev/null 2>&1
  fi
}

setup_nvm_node() {
  echo "Setting up NVM and Node.js..."

  # Checking if user docker-primary exists
  if id "docker-primary" &>/dev/null; then
    # Running the NVM installation as docker-primary
    sudo -u docker-primary bash <<EOF
    curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash

    export NVM_DIR="$DEFAULT_NVM_DIR"

    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

    if ! nvm install "$NODE_VERSION"; then
      echo "Failed to install Node version $NODE_VERSION. Exiting..."
      exit 1
    fi

    nvm use "$NODE_VERSION"
    npm install -g npm
EOF
  else
    echo "User docker-primary does not exist. Exiting..."
    exit 1
  fi
}

setup_docker_rootless() {
  echo "Setting up Docker in rootless mode..."

  # Check for Docker
  if ! command -v docker &>/dev/null; then
    echo "Docker is not installed. Please install Docker to continue."
    exit 1
  fi

  # Fixing ownership for docker-primary directories if needed
  [[ "$(stat -c '%U' "$DOCKER_DIR")" != "docker-primary" ]] && sudo chown -R docker-primary:docker-primary "$DOCKER_DIR"

  # Setup docker rootless mode if needed
  if ! command -v dockerd-rootless-setuptool.sh &>/dev/null; then
    dockerd-rootless-setuptool.sh install
    {
      echo "export PATH=$DOCKER_DIR/bin:$PATH"
      echo "export DOCKER_HOST=unix:///run/user/$(id -u)/docker.sock"
      echo "export XDG_RUNTIME_DIR=/run/user/$(id -u)"
    } >>~/.bashrc
  else
    echo "Docker rootless mode is already set up."
  fi
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

cat <<EOF > "$BACKEND_DIR/tsconfig.json"
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
 && npm install --save-dev @types/node typescript ts-node \
 && npx tsc --init \
 && npm install --save express cors multer archiver express-rate-limit helmet qrcode \
 && npm install --save-dev @types/express @types/cors @types/node @types/multer @types/archiver @types/express-rate-limit @types/helmet @types/qrcode

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

build_and_run_docker() {
  echo "Building and running Docker setup..."

  cd "$PROJECT_DIR" || {
    echo "Failed to change directory to $PROJECT_DIR"
    exit 1
  }

  # Using docker compose to build the image
  docker compose build || {
    echo "Failed to build Docker image using Docker Compose"
    exit 1
  }

  # Using docker compose to run the container
  docker compose up -d || {
    echo "Failed to run Docker Compose"
    exit 1
  }

  # Listing only the containers started by docker compose
  docker compose ps
}

# Function to create directories if they don't exist
create_directory() {
  if [ ! -d "$1" ]; then
    mkdir -p "$1"
    echo "$1 created."
  fi
}

setup_project_directories() {

  # Check and create directories using the function
  create_directory "$SERVER_DIR"
  create_directory "$FRONTEND_DIR"
  create_directory "$BACKEND_DIR"
  create_directory "$STAGING_DIR"

  # Copy all the frontend files from src to tmp
  cp -r "src" "$STAGING_DIR"
  cp "tsconfig.json" "$STAGING_DIR"

  # Copy all the backend files from src to tmp
  cp -r "server" "$BACKEND_DIR"

}

cleanup() {
  local resource
  echo "Cleaning up..."

  # Check if project directory exists
  # If it does, remove it
  if [[ -d "$PROJECT_DIR" ]]; then
    rm -rf "$PROJECT_DIR"
  fi

  # Check if docker-compose.yml exists
  # If it does, use docker compose to stop the containers
  if [[ -f "$PROJECT_DIR/docker-compose.yml" ]]; then
    docker compose -f "$PROJECT_DIR/docker-compose.yml" down
  fi

  # Create an associative array of resources to clean up
  # The key is the resource name and the value is the command to clean up the resource
  # The command is executed using eval to allow for variable expansion

  declare -A resources_to_cleanup
  resources_to_cleanup["Docker images, containers, and volumes"]="docker system prune -a -f --volumes"
  resources_to_cleanup["Docker networks"]="docker network prune -f"
  resources_to_cleanup["existing project directory $PROJECT_DIR"]="rm -rf $PROJECT_DIR"

  for resource in "${!resources_to_cleanup[@]}"; do
    # Ask the user if they want to clean up the current resource
    read -rp "Do you want to remove $resource (Y/N)? " cleanup_choice

    if [[ $cleanup_choice =~ ^[Yy] ]]; then
      # Execute the cleanup command associated with the current resource
      eval "${resources_to_cleanup["$resource"]}"
    fi
  done
}

main() {
  setup_nvm_node
  setup_project_directories
  setup_docker_rootless
  create_server_configuration_files
  create_nginx_configuration
  build_and_run_docker
}

cleanup_choice="y"

if is_first_run; then
  echo "Welcome to the QR Code Generator setup script!"
else
  read -rp "Do you want to perform cleanup (Y/N)? " cleanup_choice
  [[ $cleanup_choice =~ ^[Yy] ]] && cleanup
fi

main
