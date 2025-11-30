#!/usr/bin/env bash

# ----------------------------------------------------------------------------
# INITIALIZATION

set -euo pipefail

trap "tput cnorm" EXIT # Ensures the cursor returns to normal
trap "exit 1" INT      # Ensures the script stops with Ctrl+C

# ----------------------------------------------------------------------------
# .ENV

. <(curl -fsSL https://raw.githubusercontent.com/stenioas/bash-toolkit/main/bash-toolkit.lib)

TEMP_CLONE_DIR="$(mktemp -d)"

# ----------------------------------------------------------------------------
# EXECUTION

main() {
  _print_title "AUR helper installation"
  if pacman -Qi yay &> /dev/null; then
    _print_msg "YAY is already installed!"
    return
  fi

  git clone https://aur.archlinux.org/yay.git "${TEMP_CLONE_DIR}/yay"
  cd "${TEMP_CLONE_DIR}/yay"
  makepkg -csi --noconfirm
  cd ${HOME}

  _print_msg "AUR helper installation completed successfully!"
}

main
