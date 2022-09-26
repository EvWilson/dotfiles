import os, subprocess
import libmgr.utils as utils

# Purpose: hold quick, one-off scripts and higher level functions

# TODO: update this to packer way
def refresh_plugins():
    utils.run_command("nvim +PlugInstall +PlugClean +PlugUpdate +UpdateRemotePlugins")

# Create symlinks from where these files are supposed to be back to the versions
# within the dotfile directory
# Make sure basenames line up (looking at you, tmux)
def link():
    print("Checking for missing config symlinks...")
    links = [
        ".config/nvim/init.lua",
        ".tmux.conf",
        ".config/alacritty/alacritty.yml",
    ]
    for l in links:
        dest = f"{utils.home()}/{l}"
        if os.path.isfile(dest):
            continue
        src = f"{utils.dotfile_dir()}/{os.path.basename(dest)}"
        print(f"Link {dest} not found, creating {src} -> {dest}")
        os.makedirs(os.path.dirname(dest), exist_ok=True)
        os.symlink(src, dest)

