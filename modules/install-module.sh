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

# ----------------------------------------------------------------------------
# .ENV

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. <(curl -fsSL https://raw.githubusercontent.com/stenioas/bash-toolkit/main/bash-toolkit.lib)

IFS=$'\n\t'

MODULE="$1"
MODULE_FILE="${SCRIPT_DIR}/../modules/${MODULE}.yml"

# PACKAGE LIST

# ----------------------------------------------------------------------------
# EXECUTION

main() {
  #------------------------------#
  # CHECK DEPENDENCIES
  #------------------------------#
  if ! command -v yq &> /dev/null; then
    sudo pacman -S --noconfirm --needed "go-yq"
  fi


  #------------------------------#
  # INSTALLATION
  #------------------------------#
  _print_title "MODULE: ${MODULE}"
  
  if [[ -f ${MODULE_FILE} ]]; then
    mapfile -t PKG_LIST < <(yq -r ".packages[]" "${MODULE_FILE}")
    mapfile -t CMD_LIST < <(yq -r ".commands[]" "${MODULE_FILE}")
    mapfile -t SVC_LIST < <(yq -r ".services[]" "${MODULE_FILE}")
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
      sudo systemctl enable --now "${service}" || { echo "$(set_bred)Error:$(reset) Failed to enable service: ${service}"; exit 1; }
    done
  fi
}
