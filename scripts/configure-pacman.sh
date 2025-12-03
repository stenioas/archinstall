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
  if ! command -v reflector &> /dev/null; then
    sudo pacman -S --noconfirm --needed "reflector"
  fi

  _print_title "Pacman Configuration"
  _print_msg "Configuring pacman.conf..."
  sudo sed -i '4,$s/^#Color/Color/' /etc/pacman.conf
  sudo sed -i '4,$s/^#VerbosePkgLists/VerbosePkgLists/' /etc/pacman.conf
  sudo sed -i 's/^ParallelDownloads = [0-9]\+/ParallelDownloads = 12/' /etc/pacman.conf
  sudo sed -i '/^ParallelDownloads/a ILoveCandy' /etc/pacman.conf
  
  # Enable multilib if it exists and is commented
  _print_msg "Enabling multilib repository..."
  sudo sed -i '/^#\[multilib\]/{N;s/#\[multilib\]\n#/[multilib]\n/}' /etc/pacman.conf

  _print_msg "Updating mirrorlist..."
  sudo reflector -c Brazil --latest 6 --sort rate --verbose --save /etc/pacman.d/mirrorlist

  sudo pacman -Sy

  _print_msg "Configuring pacman completed successfully!"
}

main
