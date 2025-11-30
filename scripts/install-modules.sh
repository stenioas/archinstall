#!/usr/bin/env bash

# ----------------------------------------------------------------------------
# INITIALIZATION

set -euo pipefail

trap "tput cnorm" EXIT # Ensures the cursor returns to normal
trap "exit 1" INT      # Ensures the script stops with Ctrl+C
sudo -v                # Ensures the sudo password is ready

# ----------------------------------------------------------------------------
# .ENV

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. <(curl -fsSL https://raw.githubusercontent.com/stenioas/bash-toolkit/main/bash-toolkit.lib)

# ----------------------------------------------------------------------------
# EXECUTION

main() {
  local modules=$(yq e ".modules[]" "${SCRIPT_DIR}/../postinstall.config.yml")

  for module in $modules; do
    _print_title "Installing module: ${module}"
    ${SCRIPT_DIR}/../modules/install-module.sh "${module}"
  done
}

main
