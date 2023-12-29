#!/usr/bin/env bash

set -euo pipefail

function generate_file_paths() {
  local file_name="${1}"

  if [[ ! -f "${file_name}" ]]; then
    echo "Nginx configuration file not found: ${file_name}"
    echo "Generating nginx configuration file..."

    mkdir -p "$(dirname "${file_name}")"
    touch "${file_name}"
  fi

}
