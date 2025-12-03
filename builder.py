#!/usr/bin/env python3

import argparse
import os
import sys


# Attempt to import PyYAML. This dependency must be installed via 
# system package manager (python3-yaml/python-yaml) or pip.
try:
    import yaml
except ImportError:
    print("Error: PyYAML module is missing.", file=sys.stderr)
    print("Please install it using: sudo pacman -S python-yaml (Arch) or sudo apt install python3-yaml (Pop!_OS)", file=sys.stderr)
    sys.exit(1)


def load_yaml(path):
    """Load a YAML file safely."""
    if not os.path.exists(path):
        raise FileNotFoundError(f"File '{path}' not found.")
    
    with open(path, 'r', encoding="utf-8") as f:
        # returns None if file is empty, so we default to empty dict
        return yaml.safe_load(f) or {}


def collect_builder_modules(config):
    """
    Iterates through modules defined in config and aggregates lists.
    Returns sets/lists of commands, packages, and services.
    """
    commands = set()
    packages = set()
    aur_packages = set()
    services = set()

    # Get the list of modules from the configuration
    module_list = config.get("modules", [])

    for module in module_list:
        # Construct the path based on your structure: ./modules/category/name.yml or ./modules/name.yml
        module_path = f"./modules/{module}.yml"
        
        if not os.path.exists(module_path):
            print(f"Warning: Module file '{module_path}' not found. Skipping.", file=sys.stderr)
            continue

        try:
            module_src = load_yaml(module_path)
            
            # Update sets with data from the module, ensuring they are lists before update
            if module_src.get("commands"):
                commands.update(module_src["commands"])
            
            if module_src.get("packages"):
                packages.update(module_src["packages"])
            
            if module_src.get("aur_packages"):
                aur_packages.update(module_src["aur_packages"])
                
            if module_src.get("services"):
                services.update(module_src["services"])
                
        except Exception as e:
            print(f"Error reading module '{module}': {e}", file=sys.stderr)

    return commands, sorted(packages), sorted(aur_packages), sorted(services)


def main():
    parser = argparse.ArgumentParser(
        description="List packages, commands, and services from builder modules (YAML)."
    )
    
    # Made --list required since we are no longer generating an output file
    parser.add_argument(
        "-l", "--list",
        choices=["commands", "packages", "aur_packages", "services"],
        required=True,
        help="Type of list required: commands, packages, aur_packages or services."
    )
    
    parser.add_argument(
        "-m", "--module",
        metavar="MODULE",
        help="Target a specific module (overrides config file). E.g. de/gnome or gfx/intel."
    )
    
    parser.add_argument(
        "-c", "--config",
        default="./builderrc.yml",
        help="Path to the main configuration file listing the modules. Defaults to ./builderrc.yml"
    )

    args = parser.parse_args()

    # Determine configuration source: single module arg or config file
    if args.module:
        builder_config = {"modules": [args.module]}
    else:
        try:
            builder_config = load_yaml(args.config)
        except Exception as e:
            print(f"Error loading configuration: {e}", file=sys.stderr)
            sys.exit(1)

    try:
        commands, packages, aur_packages, services = collect_builder_modules(builder_config)
    except Exception as e:
        print(f"Error during module collection: {e}", file=sys.stderr)
        sys.exit(1)

    # Select output based on argument
    items = []
    if args.list == "packages":
        items = packages
    elif args.list == "commands":
        items = sorted(list(commands)) # Sorted for deterministic output
    elif args.list == "services":
        items = sorted(list(services))
    elif args.list == "aur_packages":
        items = sorted(list(aur_packages))

    # Print results to stdout
    if items:
        print("\n".join(items))

if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
