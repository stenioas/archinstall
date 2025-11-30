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
  _print_title "Bootstrap Script"
  _print_msg "Checking for Python YAML support (PyYAML)..."

  # Verifica se o modulo yaml ja pode ser importado pelo python3
  if ! python3 -c "import yaml" &> /dev/null; then
      _print_msg "PyYAML not found. Installing python-yaml via pacman..."

      sudo pacman -S --noconfirm --needed python-yaml

      _print_msg "PyYAML installed successfully."
  else
      _print_msg "PyYAML is already installed and ready to use."
  fi
}

main
