#!/bin/bash

#######################################
# description
# Globals:
#   BACKEND_PORT
#   DH_PARAMS_PATH
#   DNS_RESOLVER
#   DOMAIN_NAME
#   INTERNAL_LETS_ENCRYPT_DIR
#   NGINX_PORT
#   NGINX_SSL_PORT
#   PROJECT_ROOT_DIR
#   SUBDOMAIN
#   TIMEOUT
#   USE_LETS_ENCRYPT
#   internal_dirs
#   ssl_paths
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
configure_nginx() {
  echo "Creating NGINX configuration..."

  # Define local variables for the configuration
  local backend_scheme="http"
  local ssl_config=""
  local token_directive=""
  local server_name="${DOMAIN_NAME}"
  local listen_directive="listen $NGINX_PORT;
        listen [::]:$NGINX_PORT;"
  local ssl_listen_directive=""
  local acme_challenge_server_block=""

  # Handle SUBDOMAIN configuration if necessary
  if [[ $SUBDOMAIN != "www" && -n $SUBDOMAIN     ]]; then
    server_name="${SUBDOMAIN}.${DOMAIN_NAME}"
  fi

  # Update server_name_directive to include both domain and SUBDOMAIN if using Let's Encrypt
  local server_name_directive="server_name ${server_name};"

  # Handle Let's Encrypt configuration
  if [[ $USE_LETS_ENCRYPT == "yes"   ]] || [[ $USE_SELF_SIGNED_CERTS == "true" ]]; then
    backend_scheme="https"
    token_directive="server_tokens off;"
    server_name_directive="server_name ${DOMAIN_NAME} ${SUBDOMAIN}.${DOMAIN_NAME};"
    ssl_listen_directive="listen $NGINX_SSL_PORT ssl;
        listen [::]:$NGINX_SSL_PORT ssl;"

    # Configure the SSL settings
    ssl_config="
        ssl_protocols TLSv1.2 TLSv1.3;
        ssl_prefer_server_ciphers on;
        ssl_ciphers 'ECDH+AESGCM:ECDH+AES256:ECDH+AES128:DH+3DES:!ADH:!AECDH:!MD5';
        ssl_buffer_size 8k;
        ssl_dhparam ${ssl_paths[DH_PARAMS_PATH]};
        ssl_ecdh_curve secp384r1;
        ssl_session_tickets off;
        ssl_stapling on;
        ssl_stapling_verify on;

        resolver ${DNS_RESOLVER} valid=300s;
        resolver_timeout ${TIMEOUT};

        ssl_certificate ${internal_dirs[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/fullchain.pem;
        ssl_certificate_key ${internal_dirs[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/privkey.pem;
        ssl_trusted_certificate ${internal_dirs[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/fullchain.pem;"

    acme_challenge_server_block="server {
        listen 80;
        listen [::]:80;
        server_name ${server_name};

        location / {
            return 301 https://\$host\$request_uri;
        }

        location /.well-known/acme-challenge/ {
            allow all;
            root /usr/share/nginx/html;
        }
    }"

  fi

  # Backup existing configuration
  if [[ -f "${PROJECT_ROOT_DIR}/nginx.conf" ]]; then
    cp "${PROJECT_ROOT_DIR}/nginx.conf" "${PROJECT_ROOT_DIR}/nginx.conf.bak"
    echo "Backup created at ${PROJECT_ROOT_DIR}/nginx.conf.bak"
  fi

  # Write the final configuration
  cat <<- EOF > "${PROJECT_ROOT_DIR}/nginx.conf"
worker_processes auto;
events {
    worker_connections 1024;
}
http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        ${listen_directive}
        ${ssl_listen_directive}
        ${token_directive}
        ${server_name_directive}
        ${ssl_config}

        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
            try_files \$uri \$uri/ /index.html;
            # Security headers
            add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
            add_header X-Frame-Options "DENY" always;
            add_header X-Content-Type-Options nosniff always;
            add_header X-XSS-Protection "1; mode=block" always;
            add_header Referrer-Policy "strict-origin-when-cross-origin" always;
        }

        location /qr/ {
            proxy_pass ${backend_scheme}://backend:${BACKEND_PORT};
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
    $acme_challenge_server_block
 }
EOF

  # Check for errors in writing the configuration
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to write NGINX configuration."
    return 1
  fi

  cat "${PROJECT_ROOT_DIR}/nginx.conf"
  # Output the result
  echo "NGINX configuration written to ${PROJECT_ROOT_DIR}/nginx.conf"
}
