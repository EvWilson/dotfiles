import subprocess, json, os, platform, sys, shutil, tarfile
from urllib.request import urlopen

def run_command(command):
    cmdArr = command.split(' ')
    return subprocess.run(cmdArr, text=True, check=True).stdout

def home():
    return os.environ["HOME"]

def tools_dir():
    return f"{home()}/tools"

def dotfile_dir():
    return os.path.split(os.path.dirname(os.path.realpath(__file__)))[0]

def mkdirs_if_not_exist(pathname):
    if not os.path.exists(pathname):
        os.makedirs(pathname)

def rm_dir_if_exists(pathname):
    if os.path.exists(pathname):
        if os.path.isdir(pathname):
            shutil.rmtree(pathname)
        else:
            print(f"Given pathname is not a directory ({pathname}), exiting")
            sys.exit(1)

def curl_to_file(url, dest_path):
    with urlopen(url) as response:
        with open(dest_path, 'wb') as dest:
            while True:
                chunk = response.read(16384)
                if chunk:
                    dest.write(chunk)
                else:
                    break

def curl_to_string(url):
    with urlopen(url) as response:
        return response.read().decode('utf-8')

def curl_to_json(url):
    return json.loads(curl_to_string(url))

def get_latest_release(repo_name):
    url = f"https://api.github.com/repos/{repo_name}/releases/latest"
    return curl_to_json(url)["tag_name"]

# Only wanting to actively support Linux x86, Mac x86, and Mac arm64 at this time
def get_platform():
    supported_systems = ['Linux_x86_64', 'Darwin_x86_64', 'Darwin_arm64']
    system = platform.system()
    machine = platform.machine()
    if f"{system}_{machine}" not in supported_systems:
        print(f"Unrecognized platform, aborting: {system}_{machine}")
        sys.exit(1)
    return [platform.system(), platform.machine()]

def check_platform():
    get_platform()

def extract_tarfile(src_tarfile, dest_dirname):
    file_obj = tarfile.open(src_tarfile, "r")
    file_obj.extractall(dest_dirname)
    file_obj.close()
