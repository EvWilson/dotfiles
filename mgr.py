#!/usr/bin/env python3

# Purpose: make managing my workflow easier
# Usage: see main (at bottom) or run with no args

import os, platform, sys

def dotfile_dir():
    return os.path.dirname(os.path.realpath(__file__))

def home():
    return os.environ["HOME"]

def check_platform():
    supported_systems = ['Linux_x86_64', 'Darwin_x86_64', 'Darwin_arm64']
    system = platform.system()
    machine = platform.machine()
    if f"{system}_{machine}" not in supported_systems:
        print(f"Unrecognized platform, aborting: {system}_{machine}")
        sys.exit(1)

def link():
    print("Checking for missing config symlinks...")
    links = [
        ".config/nvim/init.lua",
        ".tmux.conf",
        ".config/alacritty/alacritty.yml",
    ]
    for l in links:
        dest = f"{home()}/{l}"
        if os.path.isfile(dest):
            continue
        src = f"{dotfile_dir()}/{os.path.basename(dest)}"
        print(f"Link {dest} not found, creating {src} -> {dest}")
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        os.symlink(src, dest)

def print_usage(operations):
    print("Usage: mgr.py <operation>")
    for op, val in operations.items():
        print(f" {op}\t{val[0]}")

def main():
    check_platform()

    # Here's the available operations and their descriptions
    operations = {
        "link": ["symlinks configs for nvim and tmux", link],
    }

    # Make sure there's one arg, then execute its function
    if len(sys.argv) <= 1 or len(sys.argv) > 2:
        print_usage(operations)
        return 1
    operations[sys.argv[1]][1]()

if __name__=="__main__":
    main()
