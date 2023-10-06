#!/bin/bash

set -euo pipefail

# Constants
readonly NODE_VERSION="20.8.0"
readonly PROJECT_DIR="$HOME/qr-code-generator"
readonly BACKEND_DIR="$PROJECT_DIR/backend"
readonly FRONTEND_DIR="$PROJECT_DIR/frontend"
readonly SOURCE_DIR="$FRONTEND_DIR/src"
readonly SERVER_DIR="$PROJECT_DIR/saved_qrcodes"
readonly DOCKER_DIR="/home/docker-primary"
readonly DEFAULT_NVM_DIR="$HOME/.nvm"
readonly TEMP_DIR="$PROJECT_DIR/temp"
NVM_VERSION="v0.39.5"
BACKEND_PORT=3000
NGINX_PORT=8080

# Ensures the NVM directory exists
check_nvm_dir() {
  if [[ ! -d "$NVM_DIR" ]]; then
    echo "NVM_DIR is set to an invalid directory: $NVM_DIR"
    echo "Setting default NVM_DIR..."
    export NVM_DIR="$DEFAULT_NVM_DIR"
  fi
}

# Checks if a port is in use and prompts for an alternative
check_and_update_port() {
  local port_variable_name=$1
  local port_value=${!port_variable_name}
  local file_to_update=$2
  local new_port

  if netstat -tuln | grep -q ":$port_value"; then
    read -rp "Port $port_value is already in use. Please provide an alternative port: " new_port
    sed -i "s/$port_value/$new_port/g" "$file_to_update"
    eval "$port_variable_name=$new_port"
  fi
}

# Set up NVM and Node.js
setup_nvm_node() {
  echo "Setting up NVM and Node.js..."

  local AVAILABLE_VERSIONS
  AVAILABLE_VERSIONS=$(curl -s https://nodejs.org/dist/index.json | jq -r '.[].version')

  if ! echo "$AVAILABLE_VERSIONS" | grep -q "$NODE_VERSION"; then
    echo "Node version $NODE_VERSION is not available. Exiting..."
    exit 1
  fi

  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh" | bash
  NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install node
  nvm use node
  npm install -g npm
}

# Simplified docker rootless setup
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

initialize_server_project() {
  echo "Initializing server project..."

  if [[ ! -d "$PROJECT_DIR" ]]; then
    mkdir -p "$PROJECT_DIR"
  fi

  cd "$PROJECT_DIR" || {
    echo "Failed to change directory to $PROJECT_DIR"
    exit 1
  }

  if [[ -d "$FRONTEND_DIR" ]]; then
    read -rp "Frontend directory exists. Remove and recreate (Y/N)? " choice
    if [[ $choice =~ ^[Yy] ]]; then
      rm -rf "$FRONTEND_DIR"
    else
      echo "Initialization halted due to existing frontend directory."
      exit 1
    fi
  fi

  npx create-react-app frontend --template typescript

  cd "$FRONTEND_DIR"
  jq '. + {"proxy": "http://backend:3000"}' package.json >temp.json && mv temp.json package.json
  cd "$PROJECT_DIR"

  cp "$TEMP_DIR/App.tsx" "$SOURCE_DIR/App.tsx"
  cp "$TEMP_DIR/QRCodeGenerator.tsx" "$SOURCE_DIR/QRCodeGenerator.tsx"
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
    }
}
EOF
}

setup_backend() {
  echo "Setting up the backend..."

  cd "$BACKEND_DIR"

  npm init -y
  npm install express qrcode cors

  cp "$TEMP_DIR/server.js" "$BACKEND_DIR/server.js"

  cat <<EOF >"$BACKEND_DIR/Dockerfile.node"
FROM node:$NODE_VERSION

WORKDIR /usr/src/app

COPY package*.json ./

RUN npm install

COPY . .

EXPOSE ${BACKEND_PORT}

CMD ["node", "server.js"]
EOF
}

create_server_configuration_files() {
  cat <<EOF >"$FRONTEND_DIR/Dockerfile.nginx"
FROM node:$NODE_VERSION as build
WORKDIR /usr/app
COPY package*.json ./
COPY tsconfig.json ./
COPY src ./src
COPY public ./public

RUN npm install
RUN npm install --save-dev @babel/plugin-proposal-private-property-in-object
RUN npm run build

FROM nginx:alpine
COPY --from=build /usr/app/build /usr/share/nginx/html
EXPOSE $NGINX_PORT
CMD ["nginx", "-g", "daemon off;"]
EOF

  cat <<EOF >"$PROJECT_DIR/docker-compose.yml"
version: '3.8'
services:
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.node
    ports:
      - "$BACKEND_PORT:$BACKEND_PORT"
  nginx:
    build:
      context: ./frontend
      dockerfile: Dockerfile.nginx
    ports:
      - "$NGINX_PORT:$NGINX_PORT"
    volumes:
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

setup_project_directories() {
  if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Creating project directory..."
    mkdir -p "$PROJECT_DIR"
    mkdir -p "$SERVER_DIR"
    mkdir -p "$SOURCE_DIR"
    mkdir -p "$FRONTEND_DIR"
    mkdir -p "$BACKEND_DIR"
    mkdir -p "$TEMP_DIR"

    cp "src/server.js" "$TEMP_DIR/server.js"
    cp "src/App.tsx" "$TEMP_DIR/App.tsx"
    cp "src/QRCodeGenerator.tsx" "$TEMP_DIR/QRCodeGenerator.tsx"

  else
    echo "Project directory already exists."
  fi
}

# Cleanup resources
cleanup() {
  local resource
  echo "Cleaning up..."

  if [[ -f "$PROJECT_DIR/docker-compose.yml" ]]; then
    docker compose -f "$PROJECT_DIR/docker-compose.yml" down
  fi

  for resource in "Docker images, containers, and volumes" "Docker networks" "existing project directory $PROJECT_DIR"; do
    read -rp "Do you want to remove $resource (Y/N)? " cleanup_choice
    case $resource in
    "Docker images, containers, and volumes")
      [[ $cleanup_choice =~ ^[Yy] ]] && docker system prune -a -f --volumes
      ;;
    "Docker networks")
      [[ $cleanup_choice =~ ^[Yy] ]] && docker network prune -f
      ;;
    *)
      [[ $cleanup_choice =~ ^[Yy] ]] && rm -rf "$PROJECT_DIR"
      ;;
    esac
  done
}

# Main execution flow
main() {
  check_nvm_dir
  setup_project_directories
  setup_nvm_node
  setup_docker_rootless
  setup_backend
  initialize_server_project
  check_and_update_port NGINX_PORT "$PROJECT_DIR/nginx.conf"
  check_and_update_port BACKEND_PORT "$PROJECT_DIR/docker-compose.yml"
  create_server_configuration_files
  create_nginx_configuration
  build_and_run_docker
}

# Entry point
read -rp "Do you want to perform cleanup (Y/N)? " cleanup_choice
[[ $cleanup_choice =~ ^[Yy] ]] && cleanup

main
