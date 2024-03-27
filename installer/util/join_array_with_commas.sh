#!/usr/bin/env bash

set -euo pipefail

#######################################
# Perform a join operation on an array of strings using a comma as the delimiter
# Globals:
#   IFS
# Arguments:
#  None
#######################################
join_with_commas() {
  local mappings=("${@:2}")
  local result
  result=$(
    IFS=,
    echo "${mappings[*]}"
  )
  echo "${result}"
}