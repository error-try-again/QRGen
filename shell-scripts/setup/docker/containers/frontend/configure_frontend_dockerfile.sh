#!/usr/bin/env bash

#######################################
# Configures the Dockerfile for the frontend
# Globals:
#   FRONTEND_DOCKERFILE
#   NGINX_PORT
#   NODE_VERSION
#   RELEASE_BRANCH
# Arguments:
#  None
#######################################
configure_frontend_docker() {
    local frontend_submodule_url="https://github.com/error-try-again/QRGen-frontend.git"
    local origin="origin/$RELEASE_BRANCH"
    local template_name="frontend"

    cat << EOF > "$FRONTEND_DOCKERFILE"
# Use the latest version of Node.js
FROM node:$NODE_VERSION as build

# Set the default working directory
WORKDIR /usr/app

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
    git checkout "$RELEASE_BRANCH" && \
    npm install && \
    cd ..

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
EXPOSE $NGINX_PORT
CMD ["nginx", "-g", "daemon off;"]
EOF

    cat "$FRONTEND_DOCKERFILE"
}
