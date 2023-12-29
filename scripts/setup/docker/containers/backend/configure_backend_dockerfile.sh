#!/usr/bin/env bash

set -euo pipefail

#######################################
# Dynamic Dockerfile generation - Express
# Provides submodule implementation for the backend
# Spins up server using ts-node and the specified port at runtime
# Globals:
#   BACKEND_DOCKERFILE
#   BACKEND_PORT
#   NODE_VERSION
#   RELEASE_BRANCH
# Arguments:
#  None
#######################################
function configure_backend_docker() {
    local origin="origin"/"${RELEASE_BRANCH}"
    backup_existing_config "${BACKEND_DOCKERFILE}"

    cat << EOF > "${BACKEND_DOCKERFILE}"
# Use the specified version of Node.js
FROM node:${NODE_VERSION}

# Set the default working directory
WORKDIR /usr/app

# Initialize the Git repository
RUN git init

# Add or update the backend submodule
RUN git submodule add --force "${BACKEND_SUBMODULE_URL}" backend \
    && git submodule update --init --recursive

# Checkout the specific branch for each submodule
RUN cd backend \
    && git fetch --all \
    && git reset --hard "${origin}" \
    && git checkout "${RELEASE_BRANCH}" \
    && npm install \
    && cd ..

# Copies over the user configured environment variables
COPY backend/.env /usr/app/.env

# Set the backend express port
EXPOSE ${BACKEND_PORT}

# Use ts-node to run the TypeScript server file from the correct directory
CMD ["npx", "ts-node", "/usr/app/backend/src/server.ts"]

EOF
    echo "Successfully generated backend Dockerfile at $BACKEND_DOCKERFILE"
}
