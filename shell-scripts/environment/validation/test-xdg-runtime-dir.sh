#!/bin/bash

test-xdg-runtime-dir() {
  echo "Ensuring XDG_RUNTIME_DIR is set..."
  local XDG_RUNTIME_DIR
  # Update or set XDG_RUNTIME_DIR.
  if [ -z "${XDG_RUNTIME_DIR:-}" ] || [ "${XDG_RUNTIME_DIR:-}" != "/run/user/$(id -u)" ]; then
    XDG_RUNTIME_DIR="/run/user/$(id -u)"
    export XDG_RUNTIME_DIR
    echo "Set XDG_RUNTIME_DIR to ${XDG_RUNTIME_DIR}"
  fi
}
