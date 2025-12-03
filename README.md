# Arch Linux Installation

> 💡 _**This project is a personal tool.** I created it to simplify my life and automate my Arch Linux installation process. It reflects my personal choices and is not a tutorial, but rather a documented guide for my own use. Feel free to use it, adapt, modify, fork, and play around, but **use it at your own risk!** I hope it helps you too!_

## Step-by-Step Installation Guide

This section provides a step-by-step guide to install Arch Linux using the archinstall tool, the configuration files from this repository, and the `postinstall.sh` script.

For advanced configuration, module customization, and details about the builder system, see the [Configuration Guide](./configuration.md).

### 1. Connect Archinstaller to the Internet via iwctl

- Boot into the Arch Linux installer.
- Start the interactive wireless tool:

```bash
iwctl
```

- Inside iwctl, run:

```bash
device list
station <device> scan
station <device> get-networks
station <device> connect <SSID>
exit
```

- Test your connection:

```bash
ping 8.8.8.8
```

### 2. Run Reflector to Improve Mirrors

- Update the mirrorlist for faster downloads:

```bash
reflector -c Brazil --latest 10 --sort rate --save /etc/pacman.d/mirrorlist --verbose
```

_(Adjust country as needed)_

### 3. Update Package Database

- Synchronize package databases:

```bash
pacman -Syy
```

### 4. Install Git and Nano

- Install essential tools:

```bash
pacman -S git nano
```

### 5. Clone the Project

- Clone this repository:

```bash
git clone https://github.com/stenioas/archinstall.git && cd archinstall
```

### 6. Run archinstall with the Project Configuration

- Start the installer with the provided config:

```bash
archinstall --config archinstall.config.json
```

### 7. Configure Archinstall

- In the archinstall interface:
  - Set up your disk partitioning as desired.
  - Configure your user account and password.
  - Configure bluetooth if needed (for wireless peripherals).
  - Configure other options as needed.

### 8. Install

- Proceed with the installation following the archinstall prompts.
- Wait for the process to complete.
- Reboot

### 9. Reconnect to the Internet After Reboot

- After rebooting into your new Arch Linux system, connect to the internet again using `nmtui` (if using Wi-Fi):

```bash
nmtui
```

### 10. Clone the Project Again

- Clone this repository again in your new system:

```bash
git clone https://github.com/stenioas/archinstall.git && cd archinstall
```

### 11. Run the Post-Install Script

- Execute the post-install automation script:

```bash
bash postinstall.sh
```

## Contribution

Feel free to fork, open issues, or submit pull requests to improve modularity.

## License

GNU/GPL v3.0
