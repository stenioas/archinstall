#!/usr/bin/env bash

# ----------------------------------------------------------------------------
# INITIALIZATION

set -euo pipefail

trap "tput cnorm" EXIT # Ensures the cursor returns to normal
trap "exit 1" INT      # Ensures the script stops with Ctrl+C
sudo -v                # Ensures the sudo password is ready

. <(curl -fsSL https://raw.githubusercontent.com/stenioas/bash-toolkit/main/bash-toolkit.lib)

# ----------------------------------------------------------------------------
# EXECUTION

main() {
  _print_title "Modules Installation"

  mapfile -t PKG_LIST < <(./builder.py --list packages)
  mapfile -t CMD_LIST < <(./builder.py --list commands)
  mapfile -t SVC_LIST < <(./builder.py --list services)
  
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

main
