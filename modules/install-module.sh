#!/usr/bin/env bash

# ----------------------------------------------------------------------------
# INITIALIZATION

set -euo pipefail

if [ "$#" -ne 1 ]; then
  printf 'Usage: %s module_name\n' "$(basename "$0")" >&2
  exit 2
fi

trap "tput cnorm" EXIT # Ensures the cursor returns to normal
trap "exit 1" INT      # Ensures the script stops with Ctrl+C
sudo -v                # Ensures the sudo password is ready

. <(curl -fsSL https://raw.githubusercontent.com/stenioas/bash-toolkit/main/bash-toolkit.lib)

# ----------------------------------------------------------------------------
# .ENV

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

IFS=$'\n\t'

MODULE="$1"
MODULE_FILE="${SCRIPT_DIR}/${MODULE}.yml"

# ----------------------------------------------------------------------------
# EXECUTION

main() {
  _print_title "MODULE: ${MODULE}"
  
  if [[ -f ${MODULE_FILE} ]]; then
    mapfile -t PKG_LIST < <(./builder.py --list packages --module "${MODULE}")
    mapfile -t CMD_LIST < <(./builder.py --list commands --module "${MODULE}")
    mapfile -t SVC_LIST < <(./builder.py --list services --module "${MODULE}")
  else
    _print_msg "Warning: Module file not found: ${MODULE_FILE}. Skipping package installation."
    PKG_LIST=()
    CMD_LIST=()
    SVC_LIST=()
  fi
  
  if [[ ${#PKG_LIST[@]} -ne 0 ]]; then
    _print_title "Package installation"
    yay -S --noconfirm --needed "${PKG_LIST[@]}"
  fi

  if [[ ${#CMD_LIST[@]} -ne 0 ]]; then
    _print_title "Command execution"
    for cmd in "${CMD_LIST[@]}"; do
      _print_msg "==> Running: ${cmd}..."
      eval "${cmd}" || { echo "$(set_bred)Error:$(reset) Command failed: ${cmd}"; exit 1; }
    done
  fi

  if [[ ${#SVC_LIST[@]} -ne 0 ]]; then
    _print_title "Service enablement"
    for service in "${SVC_LIST[@]}"; do
      _print_msg "==> Enabling service: ${service}..."
      sudo systemctl enable "${service}" || { echo "$(set_bred)Error:$(reset) Failed to enable service: ${service}"; exit 1; }
    done
  fi
}

main
