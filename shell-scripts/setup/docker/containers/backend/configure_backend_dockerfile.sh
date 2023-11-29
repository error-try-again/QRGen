#!/bin/bash

#######################################
# Provisions npm dependencies for the backend
# Globals:
#   None
# Arguments:
#  None
#######################################
install_backend_npm_deps() {
    # Backend-specific global dependencies
    local npm_global_deps=(
        "ts-node"
        "typescript"
    )

    # Backend-specific project dependencies
    local npm_project_deps=(
        "dotenv"
        "express"
        "cors"
        "archiver"
        "express-rate-limit"
        "helmet"
        "qrcode"
        "@googlemaps/google-maps-services-js"
    )

    # Backend-specific type dependencies
    local npm_types_deps=(
        "@types/express"
        "@types/cors"
        "@types/node"
        "@types/archiver"
        "@types/qrcode"
        "@types/google.maps"
    )

    echo "RUN npm init -y"
    echo "RUN npm install -g ${npm_global_deps[*]}"
    echo "RUN npx tsc --init"
    echo "RUN npm install --save ${npm_project_deps[*]}"
    echo "RUN npm install --save-dev ${npm_types_deps[*]}"
    echo "RUN npm cache clean --force"

}

#######################################
# Dynamic Dockerfile generation - Express
# Provides submodule implementation for the backend
# Spins up server using ts-node and the specified port at runtime
# Globals:
#   BACKEND_DOCKERFILE
#   BACKEND_PORT
#   NODE_VERSION
# Arguments:
#  None
#######################################
configure_backend_docker() {
    local backend_submodule_url="https://github.com/error-try-again/QRGen-backend.git"
    local release_branch="full-release"
    local origin="origin"/"$release_branch"

    cat << EOF > "$BACKEND_DOCKERFILE"
# Use the specified version of Node.js
FROM node:$NODE_VERSION

# Set the default working directory
WORKDIR /usr/app

$(install_backend_npm_deps)

# Initialize the Git repository
RUN git init

# Add or update the backend submodule
RUN git submodule add --force "$backend_submodule_url" backend \
    && git submodule update --init --recursive

# Checkout the specific branch for each submodule
RUN cd backend \
    && git fetch --all \
    && git reset --hard "$origin" \
    && git checkout "$release_branch" \
    && cd ..

# Copies over the user configured environment variables
COPY backend/.env /usr/app/.env

# Set the backend express port
EXPOSE $BACKEND_PORT

# Use ts-node to run the TypeScript server file from the correct directory
CMD ["npx", "ts-node", "/usr/app/backend/src/server.ts"]

EOF
    cat "$BACKEND_DOCKERFILE"
}
