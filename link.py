#!/usr/bin/env python3

# Purpose: set up config symlinks

import os
import platform
import sys


def dotfile_dir():
    return os.path.dirname(os.path.realpath(__file__))


def home():
    return os.environ["HOME"]


def check_platform():
    supported_systems = ["Linux_x86_64", "Darwin_x86_64", "Darwin_arm64"]
    system = platform.system()
    machine = platform.machine()
    if f"{system}_{machine}" not in supported_systems:
        print(f"Unrecognized platform, aborting: {system}_{machine}")
        sys.exit(1)


def link():
    print("Checking for missing config symlinks...")
    links = [
        (f"{dotfile_dir()}/init.lua", f"{home()}/.config/nvim/init.lua"),
        (f"{dotfile_dir()}/tmux.conf", f"{home()}/.tmux.conf"),
        (f"{dotfile_dir()}/ghostty.conf", f"{home()}/.config/ghostty/config"),
    ]
    for src, dest in links:
        if os.path.isfile(dest) or os.path.islink(dest):
            continue
        print(f"Link {dest} not found, creating {src} -> {dest}")
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        os.symlink(src, dest)


def main():
    check_platform()
    link()


if __name__ == "__main__":
    main()
