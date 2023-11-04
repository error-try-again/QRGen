#!/bin/bash

configure_dot_env() {
  cat <<EOF >"$BACKEND_DIR/.env"
ORIGIN=$ORIGIN
PORT=$BACKEND_PORT
EOF
}
