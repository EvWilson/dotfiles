#!/usr/bin/env python3

import sys, os, subprocess

def undone():
    print("This feature is not yet done (Boo, lazy, bad)")

def link():
    HOME = os.environ["HOME"]
    DOTFILE_DIR = os.path.dirname(os.path.realpath(__file__))
    links = [
        ".config/nvim/init.vim",
        ".tmux.conf",
        ".config/nvim/coc-settings.json",
    ]
    for l in links:
        dest = f"{HOME}/{l}"
        if os.path.isfile(dest):
            continue
        src = f"{DOTFILE_DIR}/{os.path.basename(dest)}"
        print(f"Link {dest} not found, creating {src} -> {dest}")
        os.symlink(src, dest)

def refresh_plugins():
    subprocess.run(["nvim", "+PlugInstall", "+PlugClean", "+PlugUpdate", "+UpdateRemotePlugins"], check=True, text=True)

def print_usage():
    print("Usage: mgr.py <operation>")
    for op, val in operations.items():
        print(f" {op}\t{val[0]}")

def main():
    if len(sys.argv) <= 1 or len(sys.argv) > 2:
        print_usage()
        return 1

    # Here's the available operations and their descriptions
    operations = {
        "langs": ["update enabled language servers", undone],
        "link": ["symlinks configs for nvim and tmux", link],
        "fresh": ["refresh nvim plugins and packages", refresh_plugins],
        "plug": ["install vimplug"],
        "zigup": ["install Zig and ZLS in current dir"],
    }
    operations[sys.argv[1]][1]()

if __name__=="__main__":
    main()
