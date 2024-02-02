#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Simple function to echo the current time in block format
# Arguments:
#  $1 - The date format (default "[%Y-%m-%d %H:%M:%S]")
#  $2 - The timezone (default the system's timezone)
#######################################
report_timestamp() {
  local time_format="%Y-%m-%d_%H:%M:%S"
  local time
  time=$(date +"${time_format}")
  echo "${time}"
}
