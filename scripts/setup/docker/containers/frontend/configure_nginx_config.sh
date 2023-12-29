#!/usr/bin/env bash

set -euo pipefail

#######################################
# Manage NGINX configuration generation
# Globals:
#   DOMAIN_NAME
#   acme_challenge_server_block
#   BACKEND_SCHEME
#   certs
#   resolver_settings
#   security_headers
#   server_name
#   ssl_listen_directive
#   ssl_mode_block
# Arguments:
#  None
#######################################
function configure_nginx_config() {
    server_name="server_name ${DOMAIN_NAME}"
    ssl_listen_directive=""
    ssl_mode_block=""
    resolver_settings=""
    certs=""
    security_headers=""
    acme_challenge_server_block=""
    backup_existing_config "${NGINX_CONF_FILE}"
    configure_subdomain
    configure_https
    configure_acme_challenge
    write_nginx_config
}

#######################################
# Determine if a subdomain is being used and configure the server_name accordingly
# Globals:
#   DOMAIN_NAME
#   SUBDOMAIN
#   server_name
# Arguments:
#  None
#######################################
function configure_subdomain() {
    if [[ ${SUBDOMAIN} != "www" && -n ${SUBDOMAIN} ]]; then
        server_name+=" ${SUBDOMAIN}.${DOMAIN_NAME}"
  fi
}

#######################################
# Determine if HTTPS is being used and configure the server accordingly
# Globals:
#   DNS_RESOLVER
#   NGINX_SSL_PORT
#   TIMEOUT
#   USE_LETSENCRYPT
#   USE_SELF_SIGNED_CERTS
#   backend_scheme
#   resolver_settings
#   ssl_listen_directive
# Arguments:
#  None
#######################################
# bashsupport disable=BP5006
function configure_https() {
    if [[ ${USE_LETSENCRYPT} == "true" ]] || [[ ${USE_SELF_SIGNED_CERTS} == "true" ]]; then
      BACKEND_SCHEME="https"
      ssl_listen_directive="listen ${NGINX_SSL_PORT} ssl;"
      ssl_listen_directive+=$'\n'
      ssl_listen_directive+="        listen [::]:""${NGINX_SSL_PORT} ssl;"
      configure_ssl_mode
      resolver_settings="resolver ${DNS_RESOLVER} valid=300s;"
      resolver_settings+=$'\n'
      resolver_settings+="        resolver_timeout ${TIMEOUT}s;"
      configure_certs
      configure_security_headers
  fi
}

#######################################
# Determine if TLS 1.2 and TLS 1.3 are being used and configure the server accordingly
# Globals:
#   USE_TLS12
#   USE_TLS13
#   ssl_mode_block
# Arguments:
#  None
#######################################
function configure_ssl_mode() {
    if [[ -n ${USE_TLS12} && -n ${USE_TLS13} ]]; then
    ssl_mode_block=$(get_gzip)
    ssl_mode_block+=$'\n'
    ssl_mode_block+=$(get_ssl_protocol_compatibility)
    ssl_mode_block+=$'\n'
    ssl_mode_block+=$(get_ssl_additional_config)
  else
    ssl_mode_block=$(get_gzip)
    ssl_mode_block+=$'\n'
    ssl_mode_block+=$(tls_protocol_one_three_restrict)
    ssl_mode_block+=$'\n'
    ssl_mode_block+=$(get_ssl_additional_config)
  fi
}

#######################################
# Turn off gzip compression for HTTPS
# Globals:
#   None
# Arguments:
#  None
#######################################
function get_gzip() {
  if [[ -n ${USE_GZIP} ]]; then
        cat <<- EOF
gzip on;
        gzip_comp_level 6;
        gzip_vary on;
        gzip_min_length 150;
        gzip_proxied any;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
EOF
  else
        cat <<- EOF
gzip off;
EOF
  fi
}

#######################################
# description
# Arguments:
#  None
#######################################
function get_ssl_protocol_compatibility() {
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
function get_ssl_additional_config() {
    cat <<- EOF
        ssl_prefer_server_ciphers on;
        ssl_ciphers 'ECDH+AESGCM:ECDH+AES256:!DH+3DES:!ADH:!AECDH:!MD5:!ECDHE-RSA-AES256-SHA384:!ECDHE-RSA-AES256-SHA:!ECDHE-RSA-AES128-SHA256:!ECDHE-RSA-AES128-SHA:!RC2:!RC4:!DES:!EXPORT:!NULL:!SHA1';
        ssl_buffer_size 8k;
        ssl_dhparam ${DH_PARAMS_PATH};
        ssl_ecdh_curve secp384r1;
        ssl_stapling on;
        ssl_stapling_verify on;
        ssl_session_cache shared:SSL:10m;
        ssl_session_timeout 10m;
EOF
}

#######################################
# A more restrictive TLS 1.3 configuration, which disables TLS 1.2 and lower
# Arguments:
#  None
#######################################
function tls_protocol_one_three_restrict() {
    cat <<- EOF
        ssl_protocols TLSv1.3;
EOF
}

#######################################
# Configures the certificates for HTTPS
# Globals:
#   DOMAIN_NAME
#   INTERNAL_LETSENCRYPT_DIR
#   certs
#   internal_dirs
# Arguments:
#  None
#######################################
function configure_certs() {
      certs="
        ssl_certificate /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem;
        ssl_trusted_certificate /etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem;"
}

#######################################
# Configures the security headers for HTTPS
# Globals:
#   USE_LETSENCRYPT
#   security_headers
# Arguments:
#  None
#######################################
function configure_security_headers() {
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
            add_header Content-Security-Policy \"default-src 'self'; object-src 'none'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https://*.tile.openstreetmap.org; media-src 'none'; frame-src 'none'; font-src 'self'; connect-src 'self';\";"

  if [[ ${USE_LETSENCRYPT} == "true" ]]; then
    security_headers+="

            # HTTP Strict Transport Security (HSTS) for 1 year, including subdomains
            add_header Strict-Transport-Security 'max-age=31536000; includeSubDomains' always;"
  fi
}

#######################################
# Configures the ACME challenge block for HTTPS/LE
# Globals:
#   USE_LETSENCRYPT
#   acme_challenge_server_block
#   server_name
# Arguments:
#  None
#######################################
function configure_acme_challenge() {
    if [[ ${USE_LETSENCRYPT} == "true" ]]; then
        acme_challenge_server_block="server {
          listen 80;
          listen [::]:80;
          ${server_name};
          location /.well-known/acme-challenge/ {
              allow all;
              root /usr/share/nginx/html;
          }
          location / {
              return 301 https://\$host\$request_uri; # Redirect all non-ACME challenge HTTP traffic to HTTPS
          }
      }"
  fi
}

#######################################
# Checks if an existing NGINX configuration exists and backs it up if it does
# Globals:
#   NGINX_CONF_FILE
# Arguments:
#  None
#######################################
function backup_existing_config() {
    local file
    file=$1
    if [[ -f ${file} ]]; then
        cp "${file}" "${file}.bak"
        echo "Backup created at \"${file}.bak\""
  fi
}

#######################################
# Generates an NGINX configuration for the QR endpoint if the release branch is full-release
# Globals:
#   BACKEND_PORT
#   BACKEND_SCHEME
#   RELEASE_BRANCH
# Arguments:
#  None
#######################################
function write_endpoints() {
  if [[ ${RELEASE_BRANCH} == "full-release" ]]; then

    [[ -v BACKEND_SCHEME ]] || echo "Error: BACKEND_SCHEME is not set"
    [[ -v BACKEND_PORT  ]] || echo "Error: BACKEND_PORT is not set"

    local endpoint="/qr/"
    local proxy_pass="proxy_pass ${BACKEND_SCHEME}://${BACKEND_UPSTREAM_NAME}:${BACKEND_PORT};"
    local proxy_set_header_host="proxy_set_header Host \$host;"
    local proxy_set_header_x_real_ip="proxy_set_header X-Real-IP \$remote_addr;"
    local proxy_set_header_x_forwarded_for="proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;"

    echo "location ${endpoint} {"
    echo "            ${proxy_pass}"
    echo "            ${proxy_set_header_host}"
    echo "            ${proxy_set_header_x_real_ip}"
    echo "            ${proxy_set_header_x_forwarded_for}"
    echo "        }"
  fi
}

#######################################
# Writes the NGINX configuration to the NGINX configuration file
# Globals:
#   NGINX_CONF_FILE
#   acme_challenge_server_block
#   certs
#   resolver_settings
#   security_headers
#   server_name
#   ssl_listen_directive
#   ssl_mode_block
# Arguments:
#  None
#######################################
function write_nginx_config() {
    cat <<- EOF > "${NGINX_CONF_FILE}"
worker_processes auto;
${NGINX_PID}
${NGINX_ERROR_LOG}

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        ${NGINX_ACCESS_LOG}
        ${ssl_listen_directive}
        ${server_name};
        ${ssl_mode_block}
        ${resolver_settings}
        ${certs}

        location / {
            root /usr/share/nginx/html;
            index index.html index.htm;
            try_files \$uri \$uri/ /index.html;

            expires 1y;
            add_header Cache-Control public;

            ${security_headers}
        }

        location /robots.txt {
            root /usr/share/nginx/html;
            access_log off;
            log_not_found off;
        }

        $(write_endpoints)
    }
    ${acme_challenge_server_block}
}
EOF
   echo "NGINX configuration written to ${NGINX_CONF_FILE}"
}
