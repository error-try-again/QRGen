#!/bin/bash

is_port_in_use() {
  local port="$1"
  if lsof -i :"$port" >/dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}
