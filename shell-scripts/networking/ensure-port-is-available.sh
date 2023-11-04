#!/bin/bash

ensure_port_available() {
  local port="$1"
  if is_port_in_use "$port"; then
    echo "Port $port is already in use."
    read -rp "Please provide an alternate port or Ctrl+C to exit: " port
    port="${port:-$default_port}"
  fi
  NGINX_PORT="$port"
}
