#!/usr/bin/env bash

# ----------------------------------------------------------------------------
# INITIALIZATION

set -euo pipefail

trap "tput cnorm" EXIT # Ensures the cursor returns to normal
trap "exit 1" INT      # Ensures the script stops with Ctrl+C
sudo -v                # Ensures the sudo password is ready

# ----------------------------------------------------------------------------
# .ENV

. <(curl -fsSL https://raw.githubusercontent.com/stenioas/bash-toolkit/main/bash-toolkit.lib)

TEMP_CLONE_DIR="$(mktemp -d)"

# ----------------------------------------------------------------------------
# EXECUTION

main() {
  _print_title "Themes installation"
  
  _print_msg "Installing Papirus Icon Theme..."
  sudo pacman -S --noconfirm --needed "papirus-icon-theme"
  dconf write /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"

  _print_msg "Installing Catppuccin GTK Theme..."
  git clone https://github.com/Fausto-Korpsvart/Catppuccin-GTK-Theme.git "${TEMP_CLONE_DIR}/Catppuccin-GTK-Theme"
  cd "${TEMP_CLONE_DIR}/Catppuccin-GTK-Theme"
  ./themes/install.sh -t lavender -s compact -l
  dconf write /org/gnome/desktop/interface/gtk-theme "'Catppuccin-Lavender-Dark-Compact'"
  cd ${HOME}

  _print_msg "Themes installation completed successfully!"
}

main
