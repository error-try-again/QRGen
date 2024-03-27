#!/usr/bin/env bash

set -euo pipefail

#######################################
# Inserts an argument into the ~/.bashrc file if it does not already exist.
# Arguments:
#   1
#######################################
insert_into_bashrc() {
  local line="$1"
  if ! grep -q "^${line}$" ~/.bashrc; then
    echo "${line}" >> ~/.bashrc
  fi
}