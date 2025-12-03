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
# .ENV

GITHUB_DIR="${HOME}/git/github"
DOTFILES_TARGET_DIR="${GITHUB_DIR}/dotfiles"
WALLPAPERS_TARGET_DIR="${GITHUB_DIR}/wallpapers"

# ----------------------------------------------------------------------------
# EXECUTION

main() {
  _print_title "Dotfiles installation"
  if [[ -d ${DOTFILES_TARGET_DIR} ]]; then
    _print_msg "Dotfiles folder already exists. A backup will be created in ${DOTFILES_TARGET_DIR}_old_$(date +%Y%m%d%H%M%S)!"
    mv "${DOTFILES_TARGET_DIR}" "${DOTFILES_TARGET_DIR}_old_$(date +%Y%m%d%H%M%S)"
  fi

  _print_msg "Cloning and installing dotfiles from GitHub..."
  git clone https://github.com/stenioas/dotfiles.git "${DOTFILES_TARGET_DIR}"
  bash "${DOTFILES_TARGET_DIR}/install-dotfiles.sh"

  if [[ -d ${WALLPAPERS_TARGET_DIR} ]]; then
    _print_msg "Wallpapers folder already exists. A backup will be created in ${WALLPAPERS_TARGET_DIR}_old_$(date +%Y%m%d%H%M%S)!"
    mv "${WALLPAPERS_TARGET_DIR}" "${WALLPAPERS_TARGET_DIR}_old_$(date +%Y%m%d%H%M%S)"
  fi

  _print_msg "Cloning wallpapers from GitHub..."
  _print_msg "Wallpapers installation..."
  git clone https://github.com/stenioas/wallpapers.git "${WALLPAPERS_TARGET_DIR}"
}

main
