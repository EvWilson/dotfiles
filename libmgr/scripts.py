import os, subprocess
import libmgr.langs as langs, libmgr.utils as utils

# Purpose: hold quick, one-off scripts and higher level functions

# All-in-one neovim plugin magic
def refresh_plugins():
    utils.run_command("nvim +PlugInstall +PlugClean +PlugUpdate +UpdateRemotePlugins")

def langup():
    langs.fetch_kotlin_lsp()

def vimplug_install():
    print("Downloading and installing vim-plug...")
    utils.run_command("curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim]")

# Create symlinks from where these files are supposed to be back to the versions
# within the dotfile directory
# Make sure basenames line up (looking at you, tmux)
def link():
    print("Checking for missing config symlinks...")
    links = [
        ".config/nvim/init.vim",
        ".tmux.conf",
        ".config/nvim/coc-settings.json",
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
