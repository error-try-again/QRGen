#!/usr/bin/env bash

set -euo pipefail

#######################################
# Map the user's choice to the appropriate function.
# Arguments:
#   1
#######################################
prompt_user_selection_switch() {
  case $1 in
    "Run Setup") setup ;;
    "Run Mock Configuration") run_mocks ;;
    "Uninstall") uninstall ;;
    "Dump logs") dump_logs ;;
    "Update Project") update_project ;;
    "Stop Project Docker Containers") stop_containers ;;
    "Prune All Docker Builds - Dangerous") purge_builds ;;
    "Quit") quit ;;
    *) echo "Invalid option." ;;
  esac
}
