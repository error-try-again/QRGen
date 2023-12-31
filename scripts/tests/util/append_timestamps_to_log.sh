#!/usr/bin/env bash

#######################################
# Generates a log file with timestamps for each line.
# Arguments:
#   log_file: The log file to add timestamps to
#######################################
function append_timestamps_to_log() {
  local log_file="${1}"
  if [[ ! -f "${log_file}" ]]; then
    print_messages "Error: ${log_file} does not exist!"
    return 1
  fi
awk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0 }' "${log_file}" >"${log_file}.tmp" &&
  mv "${log_file}.tmp" "${log_file}" ||
  echo "Error: Failed to process file!"
}
