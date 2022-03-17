import subprocess


def split(url, output_dir):
    subprocess.Popen(["spleeter","separate", "-p", "spleeter:4stems", "-o", output_dir, url])