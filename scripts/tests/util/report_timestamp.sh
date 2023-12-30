#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Simple function to echo the current time in block format
# Arguments:
#  $1 - The date format (default "[%Y-%m-%d %H:%M:%S]")
#  $2 - The timezone (default the system's timezone)
#######################################
function report_timestamp() {
  local time_format=${1:-"%Y-%m-%d_%H:%M:%S"}
  local tz=${2:-""}

  if [[ -z ${tz} ]]; then
    local time
    time=$(date +"${time_format}")
  else
    local time
    time=$(TZ=${tz} date +"${time_format}")
  fi
  echo "${time}"
}
