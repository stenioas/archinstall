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

LY_PAM_FILE="/etc/pam.d/ly"

# ----------------------------------------------------------------------------
# EXECUTION

main() {
    if ! pacman -Qi ly &> /dev/null; then
        _print_error "Ly is not installed. Skipping PAM configuration."
        exit 1
    elif [ ! -f "$LY_PAM_FILE" ]; then
        _print_error "Error: The Ly PAM file was not found at $LY_PAM_FILE."
        _print_error "Please check if Ly is installed."
        exit 1
    elif ! command -v gnome-keyring &> /dev/null; then
        _print_error "GNOME Keyring is not installed. Skipping PAM configuration for Ly."
        exit 1
    fi

    _print_msg "Starting PAM configuration for Ly..."

    _print_msg "Fixing 'auth'..."
    sudo sed -i '/pam_gnome_keyring.so/ s/^-auth/auth/' "$LY_PAM_FILE"

    # Fix the 'password' section
    _print_msg "Fixing 'password'..."
    sudo sed -i '/pam_gnome_keyring.so use_authtok/ s/^-password/password/' "$LY_PAM_FILE"

    # Corrigir a secao 'session'
    _print_msg "Fixing 'session'..."
    sudo sed -i '/pam_gnome_keyring.so auto_start/ s/^-session/session/' "$LY_PAM_FILE"

    _print_msg "PAM configuration completed successfully!"
    _print_msg "You must restart Ly (or the computer) for the changes to take effect."
}

main
