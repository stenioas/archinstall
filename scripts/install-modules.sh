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

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ----------------------------------------------------------------------------
# EXECUTION

main() {
  if ! command -v yq &> /dev/null; then
    sudo pacman -S --noconfirm --needed "go-yq"
  fi

  local modules=$(yq e ".modules[]" "${SCRIPT_DIR}/../postinstall.config.yml")

  for module in $modules; do
    _print_title "Installing module: ${module}"
    bash ${SCRIPT_DIR}/../modules/install-module.sh "${module}"
  done
}

main
