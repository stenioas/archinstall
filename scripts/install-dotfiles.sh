#!/usr/bin/env bash

# ----------------------------------------------------------------------------
# INITIALIZATION

set -euo pipefail

trap "tput cnorm" EXIT # Ensures the cursor returns to normal
trap "exit 1" INT      # Ensures the script stops with Ctrl+C
sudo -v                # Ensures the sudo password is ready

. <(curl -fsSL https://raw.githubusercontent.com/stenioas/bash-toolkit/main/bash-toolkit.lib)

# ----------------------------------------------------------------------------
# .ENV

TARGET_DIR="${HOME}/git/github/dotfiles"

# ----------------------------------------------------------------------------
# EXECUTION

main() {
  _print_title "Dotfiles installation"
  if [[ -d ${TARGET_DIR} ]]; then
    _print_msg "Dotfiles folder already exists. A backup will be created in ${TARGET_DIR}_old_$(date +%Y%m%d%H%M%S)!"
    mv ${TARGET_DIR} "${TARGET_DIR}_old_$(date +%Y%m%d%H%M%S)"
  fi

  _print_msg "Cloning and installing dotfiles from GitHub..."
  git clone https://github.com/stenioas/dotfiles.git ${TARGET_DIR}
  bash ${TARGET_DIR}/install-dotfiles.sh
}

main
