#!/bin/bash

#######################################
# Provisions npm dependencies for the frontend, depending on the release branch
# Globals:
#   release_branch
# Arguments:
#  None
#######################################
configure_npm_deps() {
    local npm_global_deps=(
        "ts-node"
        "typescript"
        "react-leaflet"
        "leaflet"
        "react"
        "react-dom"
  )
    local npm_project_deps=(
        "typescript"
        "vite"
        "jsdom"
        "vite-tsconfig-paths"
        "vite-plugin-svgr"
        "vitest"
        "vite-plugin-checker"
        "@vitejs/plugin-react"
        "@testing-library/react"
        "@testing-library/jest-dom"
        "@babel/plugin-proposal-private-property-in-object"
  )
    local npm_types_deps=(
        "@types/leaflet"
        "@types/react"
        "@types/react-dom"
        "@types/jest"
        "@types/react-leaflet"
  )

    # Add 'axios' library and its type definitions for full-release branch
    if [[ $release_branch == "full-release" ]]; then
        npm_project_deps+=("axios")
        npm_types_deps+=("@types/axios")
  fi

    # Add 'file-saver' and 'qrcode' libraries and their type definitions for full-release branch
    if [[ $release_branch == "minimal-release" ]]; then
        npm_project_deps+=("file-saver" "qrcode" "jszip")
        npm_types_deps+=("@types/file-saver" "@types/qrcode" "@types/jszip")
  fi

    echo "RUN npm install -g ${npm_global_deps[*]}"
    echo "RUN npm install --save-dev ${npm_project_deps[*]}"
    echo "RUN npm install --save-dev ${npm_types_deps[*]}"
}

#######################################
# Configures the Dockerfile for the frontend
# Globals:
#   FRONTEND_DOCKERFILE
#   NGINX_PORT
#   NODE_VERSION
#   release_branch
# Arguments:
#  None
#######################################
configure_frontend_docker() {
    local frontend_submodule_url="https://github.com/error-try-again/QRGen-frontend.git"
    local origin="origin/$release_branch"
    local template_name="frontend"

    cat << EOF > "$FRONTEND_DOCKERFILE"
# Use the latest version of Node.js
FROM node:$NODE_VERSION as build

# Set the default working directory
WORKDIR /usr/app

# Install dependencies
$(configure_npm_deps)

# Install Vite Template and remove default files
RUN npx create-vite $template_name --template react-ts && \
    rm /usr/app/frontend/src/App.tsx && \
    rm /usr/app/frontend/src/App.css

# Initialize the Git repository and handle frontend submodule
RUN git init && \
    (if [ -d "frontend" ]; then \
        echo "Removing existing frontend directory"; \
        rm -rf frontend; \
    fi) && \
    git submodule add --force "$frontend_submodule_url" frontend && \
    git submodule update --init --recursive && \
    cd frontend && \
    git fetch --all && \
    git reset --hard "$origin" && \
    git checkout "$release_branch" && \
    cd ..

COPY frontend/.env frontend/.env

# Build the project
WORKDIR /usr/app/frontend
RUN npm run build

# Setup nginx to serve the built files
FROM nginx:alpine
COPY --from=build /usr/app/frontend/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /usr/share/nginx/html/.well-known/acme-challenge && \
    chmod -R 777 /usr/share/nginx/html/.well-known
EXPOSE $NGINX_PORT
CMD ["nginx", "-g", "daemon off;"]
EOF

    cat "$FRONTEND_DOCKERFILE"
}
