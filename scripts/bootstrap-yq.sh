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

YQ_BIN_NAME="yq"
YQ_INSTALL_PATH="/usr/local/bin"

# ----------------------------------------------------------------------------
# EXECUTION

main() {
  _print_title "Bootstrap Script"
  _print_msg "Checking for yq (Mike Farah)..."

  if ! command -v "$YQ_BIN_NAME" &> /dev/null || [[ "$(yq --version 2>&1)" != *"mikefarah"* ]]; then

      _print_msg "Downloading and installing yq (Mike Farah)..."

      YQ_DOWNLOAD_URL=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | \
                      grep "browser_download_url" | \
                      grep "linux_amd64" | \
                      cut -d : -f 2,3 | \
                      tr -d \" | \
                      tr -d ' ')
      
      if [ -z "$YQ_DOWNLOAD_URL" ]; then
          _print_msg "Error: Could not find the download URL for yq."
          exit 1
      fi

      sudo wget "$YQ_DOWNLOAD_URL" -O "$YQ_INSTALL_PATH/$YQ_BIN_NAME"
      sudo chmod +x "$YQ_INSTALL_PATH/$YQ_BIN_NAME"
      
      _print_msg "yq (Mike Farah) installed at $YQ_INSTALL_PATH."
  else
      _print_msg "yq (Mike Farah) is already installed and ready to use."
  fi
}

main
