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
readonly TMP_DIR="$PROJECT_DIR/tmp"
readonly NODE_VERSION="20.8.0"

NVM_VERSION="v0.39.5"
BACKEND_PORT=3001
NGINX_PORT=8080

is_first_run() {
  if [[ ! -f $FIRST_RUN_FILE ]]; then
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

        location /generate {
            proxy_pass http://backend:$BACKEND_PORT;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }

        location /validate {
            proxy_pass http://backend:$BACKEND_PORT;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }

        location /batch {
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

  cat <<EOF >"$BACKEND_DIR/Dockerfile"
FROM node:$NODE_VERSION

WORKDIR /usr/app

RUN npm install -g typescript ts-node
RUN npm install --save-dev typescript @types/node @types/express @types/cors @types/multer @types/archiver @types/express-rate-limit @types/helmet
RUN tsc --init

COPY /tmp/server/server.ts /usr/app/server/server.ts
COPY /tmp/server/util /usr/app/util
COPY /tmp/server/ts /usr/app/ts

EXPOSE $BACKEND_PORT

CMD ["npm", "start"]
EOF

  cat <<EOF >"$FRONTEND_DIR/Dockerfile"
FROM node:$NODE_VERSION as build
WORKDIR /usr/app

# Install dependencies and create the project
RUN npm init -y
RUN npx create-vite frontend --template react-ts

WORKDIR /usr/app/frontend

# Install project dependencies
RUN npm install react-leaflet leaflet @types/leaflet
RUN npm install --save-dev @babel/plugin-proposal-private-property-in-object vite @vitejs/plugin-react vite-tsconfig-paths vite-plugin-svgr

COPY tmp/App.tsx /usr/app/frontend/src
COPY tmp/qr-code-generator.tsx /usr/app/frontend/src
COPY tmp/hooks /usr/app/frontend/src/hooks
COPY tmp/components /usr/app/frontend/src/components
COPY tmp/assets /usr/app/frontend/src/assets
COPY tmp/contexts /usr/app/frontend/src/contexts
COPY tmp/wrappers /usr/app/frontend/src/wrappers
COPY tmp/ts /usr/app/frontend/src/ts
COPY tmp/Util /usr/app/frontend/src/Util
COPY tmp/main.tsx /usr/app/frontend/src
COPY tmp/tsconfig.json /usr/app/frontend


# Build the project
RUN npm run build

FROM nginx:alpine
COPY --from=build /usr/app/frontend/dist /usr/share/nginx/html
EXPOSE $NGINX_PORT
CMD ["nginx", "-g", "daemon off;"]
EOF

  cat <<EOF >"$PROJECT_DIR/docker-compose.yml"
version: '3.8'
services:
  backend:
    build:
      context: $BACKEND_DIR
      dockerfile: Dockerfile
    ports:
      - "$BACKEND_PORT:$BACKEND_PORT"
    volumes:
      - ./backend:/usr/app
      - /usr/app/node_modules
      - ./saved_qrcodes:/usr/app/saved_qrcodes
  nginx:
    build:
      context: $PROJECT_DIR
      dockerfile: $FRONTEND_DIR/Dockerfile
    ports:
      - "$NGINX_PORT:$NGINX_PORT"
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
  create_directory "$TMP_DIR"

  # Copy all the frontend files from src to tmp
  cp -r "src"/* "$TMP_DIR"
  cp "tsconfig.json" "$TMP_DIR"

  # Copy all the backend files from src to tmp
  cp -r "server"/ "$TMP_DIR"

}

cleanup() {
  local resource
  echo "Cleaning up..."

  if [[ -d "$PROJECT_DIR" ]]; then
    rm -rf "$PROJECT_DIR"
  fi

  if [[ -f "$PROJECT_DIR/docker-compose.yml" ]]; then
    docker compose -f "$PROJECT_DIR/docker-compose.yml" down
  fi

  # List of resources to clean up
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
