#!/usr/bin/env bash

set -euo pipefail

#######################################
# Configures the Dockerfile for the frontend
# Globals:
#   FRONTEND_DOCKERFILE
#   EXPOSED_NGINX_PORT
#   NODE_VERSION
#   RELEASE_BRANCH
# Arguments:
#  None
#######################################
function generate_frontend_dockerfile() {
  print_messages "Configuring the frontend Docker environment..."
  local origin="origin/${RELEASE_BRANCH}"
  backup_existing_config "${FRONTEND_DOCKERFILE}"
  print_messages "Configuring frontend Dockerfile at ${FRONTEND_DOCKERFILE}"
  cat << EOF > "${FRONTEND_DOCKERFILE}"
# Use the latest version of Node.js
FROM node:${NODE_VERSION} as build

# Set the default working directory
WORKDIR /usr/app

# Initialize the Git repository and handle frontend submodule
RUN git init && \
    (if [ -d "frontend" ]; then \
        echo "Removing existing frontend directory"; \
        rm -rf frontend; \
    fi) && \
    git submodule add --force "${FRONTEND_SUBMODULE_URL}" frontend && \
    git submodule update --init --recursive && \
    cd frontend && \
    git fetch --all && \
    git reset --hard "${origin}" && \
    git checkout "${RELEASE_BRANCH}" && \
    npm install && \
    (if [ "${USE_GOOGLE_API_KEY}" = "true" ]; then \
        sed -i'' -e 's/export const googleSdkEnabled = false;/export const googleSdkEnabled = true;/' src/config.tsx; \
    fi)

# Build the project
WORKDIR /usr/app/frontend
RUN npm run build

# Setup nginx to serve the built files
FROM nginx:alpine
COPY frontend/sitemap.xml /usr/share/nginx/html/sitemap.xml
COPY frontend/robots.txt /usr/share/nginx/html/robots.txt
COPY --from=build /usr/app/frontend/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf

RUN mkdir -p /usr/share/nginx/html/.well-known/acme-challenge && \
    chmod -R 777 /usr/share/nginx/html/.well-known

EXPOSE ${EXPOSED_NGINX_PORT}
CMD ["nginx", "-g", "daemon off;"]
EOF

  print_messages "Successfully configured frontend Dockerfile at ${FRONTEND_DOCKERFILE}"
}
