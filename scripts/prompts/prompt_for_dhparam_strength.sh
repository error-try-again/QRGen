#!/usr/bin/env bash
# bashsupport disable=BP5006

set -euo pipefail

#######################################
# Prompts the user to select which DH Param strength they want to use.
# Globals:
#   DH_PARAM_CHOICE
#   DH_PARAM_SIZE
# Arguments:
#  None
#######################################
function prompt_for_dhparam_strength() {
  if [[ -n "${DH_PARAM_SIZE:-}" ]]; then
    echo "DH_PARAM_SIZE is already set to ${DH_PARAM_SIZE}. Skipping prompt."
    return
  fi
  echo "1: Use 2048-bit DH parameters (Faster)"
  echo "2: Use 4096-bit DH parameters (More secure)"
  prompt_numeric "Please enter your choice (1/2): " DH_PARAM_CHOICE
  case $DH_PARAM_CHOICE in
    1) DH_PARAM_SIZE=2048 ;;
    2) DH_PARAM_SIZE=4096 ;;
    *) echo "Invalid choice. Please enter 1 or 2." ;;
  esac
}
