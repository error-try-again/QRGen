#!/bin/bash

configure_frontend_docker() {
  cat << EOF > "$FRONTEND_DOCKERFILE"
# Use the latest version of Node.js
FROM node:$NODE_VERSION as build

# Set the default working directory
WORKDIR /usr/app

# Install project dependencies
RUN npm init -y \
&& npm install react-leaflet leaflet react react-dom typescript qrcode file-saver jszip \
&& npm install --save-dev vite jsdom vite-tsconfig-paths vite-plugin-svgr vitest \
&& npm install --save-dev @babel/plugin-proposal-private-property-in-object \
&& npm install --save-dev @vitejs/plugin-react @testing-library/react @testing-library/jest-dom \
&& npm install @types/leaflet @types/react @types/react-dom @types/jest @types/qrcode @types/file-saver \
&& npx create-vite frontend --template react-ts

# Delete the default App.tsx/App.css file (does not use kebab case)
RUN rm /usr/app/frontend/src/App.tsx && \
rm /usr/app/frontend/src/App.css

# Copy Project files to the container
COPY frontend/src/ /usr/app/frontend/src
COPY frontend/public/ /usr/app/frontend/public
COPY frontend/tsconfig.json /usr/app/frontend
COPY frontend/index.html /usr/app/frontend

# Move to the frontend directory before building
WORKDIR /usr/app/frontend

# Build the project
RUN npm run build

# Install nginx
FROM nginx:alpine

# Copy the build files to the nginx directory
COPY --from=build /usr/app/frontend/dist /usr/share/nginx/html

# Create .well-known and .well-known/acme-challenge directories
RUN mkdir /usr/share/nginx/html/.well-known/ && \
mkdir /usr/share/nginx/html/.well-known/acme-challenge

# Set permissions for the .well-known directory so certbot can access it
RUN chmod -R 777 /usr/share/nginx/html/.well-known

# Set the nginx port
EXPOSE $NGINX_PORT

# Run nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
EOF

  cat "$FRONTEND_DOCKERFILE"
}
