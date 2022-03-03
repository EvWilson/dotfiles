import subprocess, json, os
from urllib.request import urlopen

def run_command(command):
    cmdArr = command.split(' ')
    return subprocess.run(cmdArr, text=True, check=True).stdout

def get_latest_release(repo_name):
    resp = ""
    with urlopen(f"https://api.github.com/repos/{repo_name}/releases/latest") as response:
        resp = response.read().decode('utf-8')
    return json.loads(resp)["tag_name"]

def home():
    return os.environ["HOME"]

def dotfile_dir():
    return os.path.split(os.path.dirname(os.path.realpath(__file__)))[0]

def curl_to_file(url, dest_path):
    with urlopen(url) as response:
        with open(dest_path, 'wb') as dest:
            while True:
                chunk = response.read(16384)
                if chunk:
                    dest.write(chunk)
                else:
                    break
