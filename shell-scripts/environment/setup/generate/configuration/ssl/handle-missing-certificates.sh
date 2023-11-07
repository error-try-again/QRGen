#!/bin/bash

handle_missing_certificates() {
  update_ssl_paths

  # Check for missing certificates
  if [[ ! -f "${SSL_PATHS[PRIVKEY_PATH]}" ]] || [[ ! -f "${SSL_PATHS[FULLCHAIN_PATH]}" ]]; then
    echo "Error: Missing certificates."
    generate_self_signed_certificates
  fi
}
