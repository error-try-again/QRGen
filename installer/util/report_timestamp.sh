#!/usr/bin/env bash

set -euo pipefail

#######################################
# Report the current timestamp in the format YYYY-MM-DD_HH:MM:SS (e.g. 2021-01-01_12:34:56)
# Arguments:
#  None
#######################################
report_timestamp() {
  local time_format="%Y-%m-%d_%H:%M:%S"
  local time
  time=$(date +"${time_format}")
  echo "${time}"
}