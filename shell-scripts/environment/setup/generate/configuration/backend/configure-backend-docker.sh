#!/bin/bash

configure_backend_docker() {
  cat <<EOF >"$BACKEND_DIR/Dockerfile"
# Use the latest version of Node.js
FROM node:$NODE_VERSION

# Set the default working directory
WORKDIR /usr/app

RUN npm install -g ts-node typescript \
 && npm install --save-dev typescript ts-node jest ts-jest jsdom \
 && npx tsc --init \
 && npm install dotenv express cors multer archiver express-rate-limit helmet qrcode \
 && npm install --save-dev @types/express @types/cors @types/node @types/multer @types/archiver \
 && npm install --save-dev @types/express-rate-limit @types/helmet @types/qrcode @types/jest \

COPY $BACKEND_FILES /usr/app

# Set the backend express port
EXPOSE $BACKEND_PORT

# Use ts-node to run the TypeScript server file
CMD ["npx", "ts-node", "src/server.ts"]
EOF
}
