#!/usr/bin/env bash

set -euo pipefail

#######################################
# Map the user's choice to the appropriate function.
# Arguments:
#   1
#######################################
function prompt_user_selection_switch() {
  case $1 in
  "Run Setup") setup ;;
  "Run Mock Configuration") mock ;;
  "Uninstall") uninstall ;;
  "Dump logs") dump_logs ;;
  "Update Project") update_project ;;
  "Stop Project Docker Containers") stop_containers ;;
  "Purge Current Builds - Dangerous") purge ;;
  "Quit") quit ;;
  *) echo "Invalid selection: $1" ;;
  esac
}
