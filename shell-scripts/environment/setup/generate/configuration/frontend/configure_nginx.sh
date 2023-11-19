#!/bin/bash
. .env

#######################################
# Configures NGINX with SSL and optional settings
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
#   USE_SELF_SIGNED_CERTS
#   internal_dirs
#   ssl_paths
# Arguments:
#  None
# Returns:
#   1 on error
#######################################

#######################################
# description
# Arguments:
#   1
#######################################
log_error() {
    echo "[ERROR] $(date '+%Y-%m-%d %H:%M:%S') - $1"
}

#######################################
# description
# Arguments:
#   1
#   2
# Returns:
#   1 ...
#######################################
execute_and_check() {
    local cmd=$1
    local error_msg=$2

    if ! $cmd; then
        log_error "$error_msg"
        return 1
  fi
}

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
#   USE_SELF_SIGNED_CERTS
#   USE_SSL_BACKWARD_COMPAT
# Arguments:
#  None
# Returns:
#   1 ...
#######################################
# bashsupport disable=BP5006
configure_nginx() {
    echo "Creating NGINX configuration..."

    # Set defaults for possibly unset variables
    BACKEND_PORT=${BACKEND_PORT:-""}
    DH_PARAMS_PATH=${DH_PARAMS_PATH:-""}
    DNS_RESOLVER=${DNS_RESOLVER:-""}
    DOMAIN_NAME=${DOMAIN_NAME:-""}
    INTERNAL_LETS_ENCRYPT_DIR=${INTERNAL_LETS_ENCRYPT_DIR:-""}
    NGINX_PORT=${NGINX_PORT:-80}
    NGINX_SSL_PORT=${NGINX_SSL_PORT:-443}
    PROJECT_ROOT_DIR=${PROJECT_ROOT_DIR:-""}
    SUBDOMAIN=${SUBDOMAIN:-""}
    TIMEOUT=${TIMEOUT:-""}
    USE_LETS_ENCRYPT=${USE_LETS_ENCRYPT:-"no"}
    USE_SELF_SIGNED_CERTS=${USE_SELF_SIGNED_CERTS:-"no"}
    USE_SSL_BACKWARD_COMPAT=${USE_SSL_BACKWARD_COMPAT:-"no"}

    # Initialize local variables
    backend_scheme="http"
    server_name="${DOMAIN_NAME}"
    listen_directive="listen $NGINX_PORT; listen [::]:$NGINX_PORT;"
    ssl_listen_directive=""
    ssl_mode_block=""
    resolver_settings=""
    certs=""
    security_headers=""
    acme_challenge_server_block=""

    if execute_and_check configure_subdomain "Subdomain configuration failed." ||
       execute_and_check configure_https "HTTPS configuration failed." ||
       execute_and_check configure_acme_challenge "ACME challenge configuration failed." ||
       execute_and_check backup_existing_config "Backup of existing configuration failed." ||
       execute_and_check write_nginx_config "Writing NGINX configuration failed."; then
        echo "NGINX configuration completed successfully."
  else
        return 1
  fi
}

#######################################
# description
# Globals:
#   DOMAIN_NAME
#   SUBDOMAIN
#   server_name
# Arguments:
#  None
#######################################
configure_subdomain() {
    if [[ $SUBDOMAIN != "www" && -n $SUBDOMAIN ]]; then
        server_name="${DOMAIN_NAME} ${SUBDOMAIN}.${DOMAIN_NAME}"
  fi
}

#######################################
# description
# Globals:
#   DNS_RESOLVER
#   NGINX_SSL_PORT
#   TIMEOUT
#   USE_LETS_ENCRYPT
#   USE_SELF_SIGNED_CERTS
#   backend_scheme
#   resolver_settings
#   ssl_listen_directive
# Arguments:
#  None
#######################################
configure_https() {
    if [[ $USE_LETS_ENCRYPT == "yes" ]] || [[ $USE_SELF_SIGNED_CERTS == "yes" ]]; then
        backend_scheme="https"
        ssl_listen_directive="listen $NGINX_SSL_PORT ssl; listen [::]:$NGINX_SSL_PORT ssl;"
        configure_ssl_mode
        resolver_settings="resolver ${DNS_RESOLVER} valid=300s; resolver_timeout ${TIMEOUT};"
        configure_certs
        configure_security_headers
  fi
}

#######################################
# description
# Globals:
#   USE_SSL_BACKWARD_COMPAT
#   ssl_mode_block
# Arguments:
#  None
#######################################
configure_ssl_mode() {
    if [[ $USE_SSL_BACKWARD_COMPAT == "yes" ]]; then
        ssl_mode_block=$(get_gzip)
        ssl_mode_block+=$(get_ssl_protocol_compatibility)
        ssl_mode_block+=$(get_ssl_additional_config)
  else
        ssl_mode_block=$(get_gzip)
        ssl_mode_block+=$(tls_protocol_one_three_restrict)
        ssl_mode_block+=$(get_ssl_additional_config)
  fi
}

#######################################
# Turn off gzip compression
# Globals:
#   None
# Arguments:
#  None
#######################################
get_gzip() {
    cat <<- EOF
    gzip off;
EOF
}

#######################################
# description
# Globals:
#   DH_PARAMS_PATH
#   ssl_paths
# Arguments:
#  None
#######################################
get_ssl_protocol_compatibility() {
    cat <<- EOF
    ssl_protocols TLSv1.2 TLSv1.3;
EOF
}

#######################################
# SSL additional configuration, covering cipher suites, session cache, and other
# security-related features. This configuration is recommended for a modern secure
# Globals:
#   DH_PARAMS_PATH
#   ssl_paths
# Arguments:
#  None
#######################################
get_ssl_additional_config() {
    cat <<- EOF
    ssl_prefer_server_ciphers on;
    ssl_ciphers 'ECDH+AESGCM:ECDH+AES256:!DH+3DES:!ADH:!AECDH:!MD5:!ECDHE-RSA-AES256-SHA384:!ECDHE-RSA-AES256-SHA:!ECDHE-RSA-AES128-SHA256:!ECDHE-RSA-AES128-SHA:!RC2:!RC4:!DES:!EXPORT:!NULL:!SHA1';
    ssl_buffer_size 8k;
    ssl_dhparam ${ssl_paths[DH_PARAMS_PATH]};
    ssl_ecdh_curve secp384r1;
    ssl_stapling on;
    ssl_stapling_verify on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
EOF
}

#######################################
# description
# Globals:
#   DH_PARAMS_PATH
#   ssl_paths
# Arguments:
#  None
#######################################
tls_protocol_one_three_restrict() {
    cat <<- EOF
    ssl_protocols TLSv1.3;
EOF
}

#######################################
# description
# Globals:
#   DOMAIN_NAME
#   INTERNAL_LETS_ENCRYPT_DIR
#   certs
#   internal_dirs
# Arguments:
#  None
#######################################
configure_certs() {
      certs="ssl_certificate ${internal_dirs[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/fullchain.pem;
           ssl_certificate_key ${internal_dirs[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/privkey.pem;
           ssl_trusted_certificate ${internal_dirs[INTERNAL_LETS_ENCRYPT_DIR]}/live/${DOMAIN_NAME}/fullchain.pem;"
}

#######################################
# description
# Globals:
#   DOMAIN_NAME
#   INTERNAL_LETS_ENCRYPT_DIR
#   USE_LETS_ENCRYPT
#   internal_dirs
#   security_headers
# Arguments:
#  None
#######################################
configure_security_headers() {
  security_headers="
    # Prevent clickjacking by instructing the browser to deny rendering iframes
    add_header X-Frame-Options 'DENY' always;

    # Protect against MIME type sniffing security vulnerabilities
    add_header X-Content-Type-Options nosniff always;

    # Enable XSS filtering in browsers that support it
    add_header X-XSS-Protection '1; mode=block' always;

    # Control the information that the browser includes with navigations away from your site
    add_header Referrer-Policy 'strict-origin-when-cross-origin' always;

    # Content Security Policy
    # The CSP restricts the sources of content like scripts, styles, images, etc. to increase security
    # 'self' keyword restricts loading resources to the same origin as the document
    # Adjust the policy directives based on your application's specific needs
    add_header Content-Security-Policy \"default-src 'self';
        script-src 'self';             # Allow scripts from the same origin
        object-src 'none';             # Prevent loading plugins
        style-src 'self' 'unsafe-inline'; # Allow styles from the same origin and unsafe inline styles
        img-src 'self';                # Allow images from the same origin
        media-src 'none';              # Disallow audio and video
        frame-src 'none';              # Disallow iframes
        font-src 'self';               # Allow fonts from the same origin
        connect-src 'self';            # Restrict origins for script interfaces
    \";"

    if [[ $USE_LETS_ENCRYPT == "yes" ]]; then
        security_headers+="
            add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains' always;"
  fi
}

#######################################
# description
# Globals:
#   USE_LETS_ENCRYPT
#   acme_challenge_server_block
#   server_name
# Arguments:
#  None
#######################################
configure_acme_challenge() {
    if [[ $USE_LETS_ENCRYPT == "yes" ]]; then
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
}

#######################################
# description
# Globals:
#   PROJECT_ROOT_DIR
# Arguments:
#  None
#######################################
backup_existing_config() {
    if [[ -f "${PROJECT_ROOT_DIR}/nginx.conf" ]]; then
        cp "${PROJECT_ROOT_DIR}/nginx.conf" "${PROJECT_ROOT_DIR}/nginx.conf.bak"
        echo "Backup created at ${PROJECT_ROOT_DIR}/nginx.conf.bak"
  fi
}

#######################################
# description
# Globals:
#   BACKEND_PORT
#   PROJECT_ROOT_DIR
#   acme_challenge_server_block
#   backend_scheme
#   certs
#   listen_directive
#   resolver_settings
#   security_headers
#   server_name
#   ssl_listen_directive
#   ssl_mode_block
# Arguments:
#  None
#######################################
write_nginx_config() {
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
        server_name ${server_name};
        ${ssl_mode_block}
        ${resolver_settings}
        ${certs}

        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
            try_files \$uri \$uri/ /index.html;
            ${security_headers}
        }

        location /qr/ {
            proxy_pass ${backend_scheme}://backend:${BACKEND_PORT};
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        }
    }
    ${acme_challenge_server_block}
}
EOF

  if ! configure_nginx; then
        log_error "Writing NGINX configuration failed."
        return 1
  else
        echo "NGINX configuration written to ${PROJECT_ROOT_DIR}/nginx.conf"
  fi

}
