#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Prompts the user for the install mode.
# Globals:
#   INSTALL_MODE_CHOICE
#   RELEASE_BRANCH
# Arguments:
#  None
#######################################
function prompt_for_release_install_mode() {
  if [[ ${RELEASE_BRANCH} == "minimal-release" ]] || [[ ${RELEASE_BRANCH} == "full-release" ]]; then
    return
fi  echo "1: Install minimal release (frontend QR generation) (Limited features)"
  echo "2: Install full release (frontend QR generator and backend API/server side generation) (All features)"
  prompt_numeric "Please enter your choice (1/2): " INSTALL_MODE_CHOICE
  case ${INSTALL_MODE_CHOICE} in
    1) RELEASE_BRANCH="minimal-release" ;;
    2) RELEASE_BRANCH="full-release" ;;
    *) echo "Invalid choice. Please enter 1 or 2." ;;
  esac
}
