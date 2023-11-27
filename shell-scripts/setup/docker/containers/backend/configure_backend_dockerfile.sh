#!/bin/bash

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

# Initialize the package.json file
RUN npm init -y

# Install global dependencies
RUN npm install -g ts-node typescript

# Install project-specific dependencies
RUN npm install \
    && npm install --save-dev jest ts-jest jsdom @types/jest \
    && npx tsc --init \
    && npm install --save dotenv express cors multer archiver express-rate-limit helmet qrcode \
    && npm install --save-dev @types/express @types/cors @types/node @types/multer @types/archiver @types/qrcode \
    # Clean up the npm cache to reduce image size \
    && npm cache clean --force

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

COPY backend/.env /usr/app/.env

# Set the backend express port
EXPOSE $BACKEND_PORT

# Use ts-node to run the TypeScript server file from the correct directory
CMD ["npx", "ts-node", "/usr/app/backend/src/server.ts"]

EOF
  cat "$BACKEND_DOCKERFILE"
}
