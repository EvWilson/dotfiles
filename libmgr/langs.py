
# Strategy:
# Language binaries will hopefully largely be installed via homebrew
# Language server binaries will be installed to $HOME/.local/share/nvim/lsp

import os
import libmgr.utils as utils

def lsp_dir():
    return f"{utils.home()}/.local/share/nvim/lsp"

# TODO this needs testing but I'm tired
def fetch_kotlin_lsp():
    kot_lsp_dir = f"{lsp_dir()}/kotlin"
    os.makedirs(kot_lsp_dir)
    latest = utils.get_latest_release("fwcd/kotlin-language-server")
    server_zip_path = f"{kot_lsp_dir}/server.zip"
    utils.curl_to_file(f"https://github.com/fwcd/kotlin-language-server/releases/download/{latest}/server.zip", server_zip_path)
    utils.run_command(f"unzip {server_zip_path}")

def zig_install():
    print("Installing zig...")
    return
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
