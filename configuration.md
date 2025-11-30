# Configuration Guide

## Base Archinstall Configuration

This project also includes a base configuration for the official [archinstall](https://archinstall.archlinux.page/index.html) installer. The file `archinstall.config.json` defines essential system settings, such as:

- Kernel selection
- Locale and timezone
- Network configuration

You can customize this file to match your hardware, preferences, and installation requirements. It is used as input for the Archinstall process, ensuring a reproducible and automated base system setup before running post-installation scripts and modular configuration.

**Example: `archinstall.config.json`**

```yaml
{
  'kernels': ['linux-lts'],
  'locale_config':
    {
      'kb_layout': 'us-acentos',
      'sys_enc': 'UTF-8',
      'sys_lang': 'pt_BR.UTF-8',
    },
  'timezone': 'America/Fortaleza',
  'network_config': { 'type': 'nm' },
  'packages': ['linux-lts-headers', 'git', 'nano', 'reflector'],
  'custom_commands':
    [
      'reflector -c Brazil --latest 10 --sort rate --save /etc/pacman.d/mirrorlist',
    ],
  'app_config': { 'audio_config': { 'audio': 'pipewire' } },
  'mirror_config': { 'optional_repositories': ['multilib'] },
  'services': [],
  'version': '3.0.11',
}
```

See the [example usage](https://archinstall.archlinux.page/installing/guided.html#example-usage) for all available options and adjust as needed for your installation.

### Usage

```bash
archinstall --config archinstall.config.json
```

## Post Install Script

### Features

- Modular configuration: each file in `modules/` is a module with its own commands, package and services lists
- Supports `commands`, `packages` and `services` in each module
- Flexible selection of modules for post-installation via `builderrc.yml`
- Easily extensible for desktops (DE), display managers (DM), graphics (GFX), dotfiles, and custom hardware
- Automated pacman and AUR installation
- Custom post-installation commands
- One-command execution for full setup

### Structure

```
archinstall/
├── modules
│   ├── de
│   │   ├── gnome.yml
│   │   └── hyprland.yml
│   ├── dm
│   │   ├── gdm.yml
│   │   └── ly.yml
│   ├── gfx
│   │   ├── amd.yml
│   │   ├── intel.yml
│   │   └── nvidia.yml
│   ├── aur.yml
│   ├── bluetooth.yml
│   ├── codecs.yml
│   ├── custom.yml
│   ├── development.yml
│   ├── extras.yml
│   ├── fonts.yml
│   ├── install-module.sh
│   ├── pipewire.yml
│   ├── softwares.yml
│   ├── utilities.yml
│   └── virt-manager.yml
├── scripts
│   ├── bootstrap.sh
│   ├── configure-keyring.sh
│   ├── configure-pacman.sh
│   ├── install-aur-helper.sh
│   ├── install-dotfiles.sh
│   ├── install-modules.sh
│   └── install-themes.sh
├── archinstall.config.json
├── builder.py
├── builderrc.yml
├── configuration.md
├── draft_installation_guide.md
├── LICENSE
├── postinstall.sh
└── README.md
```

- **modules/**: Each file (or file in a subfolder) is a module. You can define `commands`, `packages` and `services` arrays in each.
- **builderrc.yml**: Only one property: `modules`, an array listing the modules to include in your post-installation. Use subfolder/module notation, e.g. `de/hyprland`.

### How to Add/Customize Modules

- Create or edit files in `modules/` or its subfolders for each environment, hardware, or configuration you want.
- Use clear names: `common`, `custom`, `dotfiles`, `de/*`, `dm/*`, `gfx/*`, etc.
- Add commands, pacman packages, AUR packages and services to each module as needed.
- Reference only the modules you want in `builderrc.yml` using the correct path (e.g. `de/hyprland`).

### Advanced: Module Commands

- Add any shell commands to the `commands` array in your module (e.g. enable services, update user dirs, setup dotfiles).

### How the Builder Works

The builder system is responsible for merging all selected modules and generating the final lists of commands, packages and services to be executed, installed and enabled, respectively, during the post-installation process. It works as follows:

1. **Module Selection:**

- The modules you want to use are defined in `builderrc.yml` under the `modules` array.
- Each module is a YAML file (or inside a subfolder) that can define its own `commands`, `packages` and `services` arrays.

2. **Merging:**

- When you run the `postinstall.sh` script, it automatically calls the `install-modules.sh` script, which in turn calls `builder.py` to read the selected modules, merge all their `commands`, `packages`, and `services`, and generate the unified lists.
- The final **package list** will be installed before executing the command list, before enabling the service list configured in the modules, and will be organized alphabetically to avoid duplicates and ensure the correct installation order.
- The final **commands list** will be executed in the order in which the modules are read, and within each module, in the order they are defined. This means the execution order is determined by the order of modules in `builderrc.yml` and the manual order of commands inside each module file.
- The final **service list** will be enabled in the order in which the modules are read, and within each module, in the order they are defined. This means the execution order is determined by the order of modules in `builderrc.yml` and the manual order of services inside each module file.

For example, if you have two modules, `custom` and `extra`, and define the modules in `builderrc.yml` as:

```yaml
modules:
  - extra
  - custom
```

And in `modules/custom.yml`:

```yaml
commands:
  - echo 'custom command 2'
  - echo 'custom command 1'
```

And in `modules/extra.yml`:

```yaml
commands:
  - echo 'extra command 1'
  - echo 'extra command 2'
```

The execution order will be:

1. `echo 'extra command 1'`
2. `echo 'extra command 2'`
3. `echo 'custom command 2'`
4. `echo 'custom command 1'`

5. **Execution:**

- The post-installation script installs all packages, runs all commands, and enables all services in the correct order.

You do not need to run `builder.py` manually. The process is fully automated by `postinstall.sh`, ensuring a modular, flexible, and reproducible setup.

### Usage

#### 1. Select your modules

Edit `builderrc.yml` and set the `modules` array to include the modules you want for your system. Use the format `folder/module` for modules inside subfolders. Example:

```yaml
modules:
  - common # always included
  - custom # hardware-specific extras (e.g. sof-firmware for Galaxy Book 4)
  - de/hyprland # desktop environment
  - dm/ly # display manager
  - gfx/intel # graphics driver
  - your_custom_module # Your own custom module
```

#### 2. Define your modules

Each module file (e.g. `modules/common.yml`, `modules/de/hyprland.yml`) can contain any of these arrays:

```yaml
commands:
  - xdg-user-dirs-update
packages:
  - nano
  - git
  - google-chrome
  - spotify
services:
  - systemctl enable fstrim.timer
```

#### 3. Run the post-installation Script

To automate the installation and configuration of all selected modules, simply run:

```bash
./postinstall.sh
```

> 💡 _The `postinstall.sh` script will automatically use the builder system to merge all selected modules, generate the commands, package and service lists, and execute the necessary steps for your setup. You do not need to run `builder.py` manually._

This script will:

- Check your connection
- Check dependencies
- Configure pacman.conf
- Install AUR Helper
- Install all pacman and AUR packages
- Execute all post-installation commands
- Enable all services
- Install dotfiles
- Configure keyring
- Install themes and icons
- Clean up installation

### Troubleshooting

- If a module is missing, the script will show an error and stop.
- Make sure all modules listed in `builderrc.yml` exist in the `modules/` folder.
- For builder help, run:

```bash
./builder.py --help
```

### Contribution

Feel free to fork, open issues, or submit pull requests to improve modularity, add new modules, or enhance automation.

### Requirements

- Arch Linux base system
- Python 3 and PyYAML
- Bash
- Internet connection for package installation

### License

GNU/GPL v3.0
