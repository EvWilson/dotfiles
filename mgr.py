#!/usr/bin/env python3

# Purpose: make managing my workflow easier
# Usage: see main (at bottom) or run with no args

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

def vimplug_install():
    subprocess.run(["curl",
        "-fLo",
        "~/.local/share/nvim/site/autoload/plug.vim",
        "--create-dirs",
        "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"],
        check=True,
        text=True)

def zig_install():
    undone()
    # Below is what was in the shell script, for reference
    # # Check that needed bins are available
    # PROGS="jq curl git"
    # for p in $PROGS; do
    #     if ! [ -x "$(command -v $p)" ]; then
    #         echo "error: $p is not installed, aborting" >&2
    #         exit 1
    #     fi
    # done

    # # Get the right platform string, because I'm also on MacOS now :/
    # PLAT='.master."x86_64-linux".tarball'
    # if [ $(uname) == "Darwin" ]; then
    #     PLAT='.master."aarch64-macos".tarball'
    # fi

    # # Install latest master revision of zig to the directory "bin" in current dir
    # ZIG_TARBALL=$(curl -s https://ziglang.org/download/index.json | jq -r $PLAT)
    # TARFILE=$(basename $ZIG_TARBALL)
    # DIRNAME=$(echo $TARFILE | sed -e "s/.tar.xz$//")
    # echo "Installing Zig tarball from: $ZIG_TARBALL"
    # curl -O $ZIG_TARBALL
    # tar xf $TARFILE
    # rm $TARFILE
    # mv $DIRNAME zig

    # # Build ZLS from source and put binary in created "zig" dir
    # cd zig
    # git clone --recurse-submodules https://github.com/zigtools/zls
    # cd zls
    # ../zig build -Drelease-safe
    # cd ..
    # mv zls zls-git
    # mv ./zls-git/zig-out/bin/zls .
    # sudo ./zls config

def print_usage(operations):
    print("Usage: mgr.py <operation>")
    for op, val in operations.items():
        print(f" {op}\t{val[0]}")

def main():
    # Here's the available operations and their descriptions
    operations = {
        "langs": ["update enabled language servers", undone],
        "link": ["symlinks configs for nvim and tmux", link],
        "fresh": ["refresh nvim plugins and packages", refresh_plugins],
        "plug": ["install vimplug", vimplug_install],
        "zigup": ["install Zig and ZLS in current dir", zig_install],
    }

    # Make sure there's one arg, then execute its function
    if len(sys.argv) <= 1 or len(sys.argv) > 2:
        print_usage(operations)
        return 1
    operations[sys.argv[1]][1]()

if __name__=="__main__":
    main()
