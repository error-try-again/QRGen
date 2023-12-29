#!/usr/bin/env bash

set -euo pipefail

# Function: display_help
# Displays detailed usage information and list of available options.
function display_help() {
    cat << EOF
Usage: $0 [OPTIONS]
A comprehensive script for managing and deploying web environments.

General Options:
  --setup                             Initialize and configure the project setup.
  --run-mocks                         Execute mock configurations for testing.
  --uninstall                         Clean up and remove project-related data.
  --dump-logs                         Collect and display system logs.
  --update                   Update the project components to the latest version.
  --stop                   Halt all related Docker containers.
  --purge                      Remove Docker builds and clean up space (Use with caution).
  --quit                              Exit the script prematurely.

Security and SSL/TLS Options:
  --enable-hsts                       Activate HTTP Strict Transport Security to enforce secure connections.
  --use-ocsp-stapling              Enable Online Certificate Status Protocol Stapling for SSL/TLS.
  ----use-tls12                    Activate support for TLS version 1.3.
  ----use-tls13                    Activate support for TLS version 1.2.
  --use-ssl                           Enable SSL/TLS support for encrypted communication.
  --dh-param-size SIZE                Set the size (in bits) for Diffie-Hellman parameters.
  --rsa-key-size SIZE                 Set the size (in bits) for RSA key generation.
  --use-must-staple                   Enable the OCSP Must Staple extension for enhanced security.

Let's Encrypt Options:
  --use-strict-permissions            Enforce strict file and directory permissions.
  --use-uir                           Upgrade insecure requests to HTTPS automatically.
  --use-dry-run                       Test the certbot configuration without making changes.
  --use-auto-renew-ssl                Enable automatic renewal of SSL certificates.
  --use-overwrite-self-signed-certs   Overwrite existing self-signed certificates.
  --use-force-renew                   Forcefully renew SSL certificates before expiration.
  --letsencrypt-email EMAIL           Define the email address for Let's Encrypt notifications.
  --use-production-ssl                Use the production SSL environment for real certificates.
  --use-lets-encrypt                  Opt-in for using Let's Encrypt free SSL/TLS certificates.
  --use-custom-domain DOMAIN          Set a custom domain for the project.

Self-Signed Certificate Options:
  --regenerate-ssl-certs              Regenerate self-signed SSL certificates for the project.
  --use-self-signed-certs             Employ self-signed certificates for development or testing.

Configuration Options:
  --backend-port PORT                 Define the port for backend services.
  --nginx-port PORT                   Set the listening port for Nginx server.
  --nginx-ssl-port PORT               Set the SSL port for Nginx server.
  --domain-name DOMAIN                Assign the domain name for the project setup.
  --backend-scheme SCHEME             Specify the communication scheme for backend (http/https).
  --subdomain SUBDOMAIN               Define a subdomain for the project's domain.
  --origin-url URL                    Assign the origin URL for resource referencing.
  --origin-port PORT                  Set the port for origin server.
  --origin ORIGIN                     Define the origin for the setup context.
  --dns-resolver RESOLVER             Specify the DNS resolver address.
  --timeout timeout                   Set the maximum time allowed for operations.
  --node-version VERSION              Specify the version of Node.js to use.
  --build-certbot-image               Build the Certbot Docker image for managing SSL certificates.
  --disable-docker-caching            Turn off Docker's build caching mechanism for fresh builds.
  --use-google-api-key                Enable using a Google API key for services like Maps.
  --google-maps-api-key KEY           Provide the Google Maps API key for integration.
  --release-branch BRANCH             Define the codebase's release branch for deployment.
  --use-gzip                          Enable gzip compression for web content.

Miscellaneous:
  --challenge-port PORT               Define the port used for ACME challenges with Let's Encrypt.
  --robots-file FILE                  Specify the path to the robots.txt file for search engine rules.
  --sitemap-xml FILE                  Define the path to the sitemap XML file for search engines.

Help and Miscellaneous:
  -h, --help                          Display this help message and exit.

Descriptions and additional information for each option can be added here for clarity and guidance.

EOF
}
