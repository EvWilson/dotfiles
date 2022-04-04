
# Strategy:
# Language binaries will hopefully largely be installed via homebrew
# Language server binaries will be installed to $HOME/.local/share/nvim/lsp

import os, shutil
import libmgr.utils as utils

def lsp_dir():
    return f"{utils.home()}/.local/share/nvim/lsp"

# TODO this needs testing but I'm tired
def fetch_kotlin_lsp():
    kot_lsp_dir = f"{lsp_dir()}/kotlin"
    os.makedirs(kot_lsp_dir)
    latest = utils.get_latest_release("fwcd/kotlin-language-server")
    remote_zip_path = f"https://github.com/fwcd/kotlin-language-server/releases/download/{latest}/server.zip"
    local_zip_path = f"{kot_lsp_dir}/server.zip"
    utils.curl_to_file(remote_zip_path, local_zip_path)
    utils.run_command(f"unzip {local_zip_path}")

def get_latest_zig_master():
    releases = utils.curl_to_json(f"https://ziglang.org/download/index.json")
    tarball_url = releases["master"][f"{url_machine}-{url_system}"]["tarball"]

def zig_install():
    use_version = "0.9.0"

    start_dir = os.getcwd()
    out_dir = f"{utils.tools_dir()}"
    print(f"Installing zig and zls to {out_dir}...")
    utils.mkdirs_if_not_exist(out_dir)

    system, machine = utils.get_platform()
    url_system, url_machine = '', ''
    if system == 'Linux':
        url_system = 'linux'
    else:
        url_system = 'macos'
    if machine == 'x86_64':
        url_machine = machine
    else:
        url_machine = 'aarch64'

    tarball_url = ""
    if use_version == "":
        tarball_url = get_latest_zig_master()
    else:
        tarball_url = f"https://ziglang.org/download/{use_version}/zig-{url_system}-{url_machine}-{use_version}.tar.xz"
    tar_filename = tarball_url.split("/")[-1]
    tar_fullpath = f"{out_dir}/{tar_filename}"
    unpacked_dirname = tar_filename.removesuffix(".tar.xz")
    utils.curl_to_file(tarball_url, tar_fullpath)
    utils.extract_tarfile(tar_fullpath, out_dir)
    os.remove(tar_fullpath)
    shutil.move(f"{out_dir}/{unpacked_dirname}", f"{out_dir}/zig")

    if use_version == "":
        print("Skipping ZLS download due to using Zig master, which I've found largely incompatible")
        return
    tarball_url = f"https://github.com/zigtools/zls/releases/download/{use_version}/{url_machine}-{url_system}.tar.xz"
    utils.mkdirs_if_not_exist(f"{out_dir}/zig/zls")
    utils.curl_to_file(tarball_url, f"{out_dir}/zig/zls/zls.tar.xz")
    os.chdir(f"{out_dir}/zig/zls")
    utils.run_command("tar xf zls.tar.xf")
    os.chdir(f"{out_dir}/zig/zls/bin")
    utils.run_command("chmod u+x ./zls && sudo ./zls config")
