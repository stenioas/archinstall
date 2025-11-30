#!/usr/bin/env bash
# ----------------------------------------------------------------------------
# Name        : postinstall.sh
# Description : Arch Linux Post-Installation Script
# Version     : 1.0.0-beta
# Author      : Stenio Silveira <stenioas@gmail.com>
# Date        : 21/10/2025
# License     : GNU/GPL v3.0

# ============================================================================
# INITIALIZATION
# ----------------------------------------------------------------------------

set -euo pipefail

trap "tput cnorm" EXIT # Ensures the cursor returns to normal
trap "exit 1" INT      # Ensures the script stops with Ctrl+C
sudo -v                # Ensures the sudo password is ready

# ============================================================================
# .ENV
# ----------------------------------------------------------------------------

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. <(curl -fsSL https://raw.githubusercontent.com/stenioas/bash-toolkit/main/bash-toolkit.lib)

SCRIPT_TITLE="Arch Linux Post-Installation Script"
SCRIPT_VERSION="1.0.0-beta"

# ============================================================================
# EXECUTION
# ----------------------------------------------------------------------------

main() {
  _check_connection


  #------------------------------#
  # WELCOME MESSAGE
  #------------------------------#
  clear

  local banner=$(cat << 'EOF'
    _    _     ____ ___ ____  
   / \  | |   |  _ \_ _/ ___| 
  / _ \ | |   | |_) | |\___ \ 
 / ___ \| |___|  __/| | ___) |
/_/   \_\_____|_|  |___|____/ 
EOF
)

  local msg=$(cat << EOF
This script is a personal tool. I created it to simplify my life
and  automate my Arch Linux post-installation process. It reflects
my choices,  and is not a tutorial or a guide. Feel free to use it,
adapt, modify, fork, and play around, but use it at your own risk!
I hope it helps you too!

See here for more details: https://github.com/stenioas/archinstall
EOF
  )

  local alert=$(cat << EOF
  
── ATTENTION! ──────────────────────────────────────────────────────
 The script will run automatically, but you may be asked for your
 password. Stay alert. Please ensure you have read the usage
 instructions entirely before proceeding.
────────────────────────────────────────────────────────────────────
EOF
  )

  _print_msg "$(set_bcyan)${banner}$(reset)"
  _print_msg "\n Welcome to my $(set_bcyan)${SCRIPT_TITLE}$(reset) - v${SCRIPT_VERSION}$(reset)"
  echo
  _print_msg "${msg}"
  _print_msg "$(set_byellow)${alert}$(reset)"
  _pause


  #------------------------------#
  # INSTALLATION
  #------------------------------#
  bash ${SCRIPT_DIR}/scripts/configure-pacman.sh
  bash ${SCRIPT_DIR}/scripts/install-aur-helper.sh
  bash ${SCRIPT_DIR}/scripts/install-modules.sh
  bash ${SCRIPT_DIR}/scripts/install-dotfiles.sh
  bash ${SCRIPT_DIR}/scripts/configure-keyring.sh
  bash ${SCRIPT_DIR}/scripts/install-themes.sh


  #------------------------------#
  # SYSTEM CLEANUP
  #------------------------------#
  _print_title "System Cleanup"
  _print_msg "Cleaning package cache..."
  sudo pacman -Scc --noconfirm

  local orphans_packages
  orphans_packages=$(pacman -Qdtq || true)
  if [[ -n "${orphans_packages//[[:space:]]/}" ]]; then
    _print_msg "Removing unnecessary packages..."
    sudo pacman -Rns --noconfirm ${orphans_packages}
  else
    _print_msg "No orphaned packages to remove!"
  fi

  _print_msg "System cleanup completed successfully!"


  #------------------------------#
  # FINISH
  #------------------------------#
  _print_msg "\n$(set_bgreen)All done! $(set_bcyan)You can now restart your system.$(reset)"
}

main
