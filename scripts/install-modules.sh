#!/usr/bin/env bash

# ----------------------------------------------------------------------------
# INITIALIZATION

set -euo pipefail

trap "tput cnorm" EXIT # Ensures the cursor returns to normal
trap "exit 1" INT      # Ensures the script stops with Ctrl+C
sudo -v                # Ensures the sudo password is ready

# shellcheck disable=SC1090
. <(curl -fsSL https://raw.githubusercontent.com/stenioas/bash-toolkit/main/bash-toolkit.lib)

# ----------------------------------------------------------------------------
# EXECUTION

main() {
  _print_title "Modules Installation"

  if ! command -v yay &> /dev/null; then
    _print_msg "==> 'yay' not found. Exiting..."
    exit 1
  fi

  mapfile -t CMD_LIST < <(./builder.py --list commands)
  mapfile -t PKG_LIST < <(./builder.py --list packages)
  mapfile -t AUR_LIST < <(./builder.py --list aur_packages)
  mapfile -t SVC_LIST < <(./builder.py --list services)
  
  if [[ ${#PKG_LIST[@]} -ne 0 ]]; then
    _print_msg "Installing packages..."
    sudo pacman -S --noconfirm --needed "${PKG_LIST[@]}"
  fi

  if [[ ${#AUR_LIST[@]} -ne 0 ]]; then
    _print_msg "Installing AUR packages..."
    yay -S --noconfirm --needed "${AUR_LIST[@]}"
  fi

  if [[ ${#CMD_LIST[@]} -ne 0 ]]; then
    _print_msg "Executing commands..."
    for cmd in "${CMD_LIST[@]}"; do
      _print_msg "==> Running: ${cmd}..."
      eval "${cmd}" || { echo "$(set_bred)Error:$(reset) Command failed: ${cmd}"; exit 1; }
    done
  fi

  if [[ ${#SVC_LIST[@]} -ne 0 ]]; then
    _print_msg "Enabling services..."
    for service in "${SVC_LIST[@]}"; do
      _print_msg "==> Enabling service: ${service}..."
      sudo systemctl enable "${service}" || { echo "$(set_bred)Error:$(reset) Failed to enable service: ${service}"; exit 1; }
    done
  fi
}

main
