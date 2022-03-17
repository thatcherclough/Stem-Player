import os
from datetime import datetime
from re import S
import shutil
import subprocess
import flask
from flask import jsonify
from flask import request
import youtube_downloader

datetime_format = "%d-%m-%Y_%H:%M:%S:%f"

app = flask.Flask(__name__)

@app.route("/api", methods=["GET"])
def api():
    ret = {"message": "Stem Player API"}
    return jsonify(ret), 200


@app.route("/api/get_stems", methods=["GET"])
def get_stems():
    import spleeter
    if "url" in request.args:
        now = datetime.now()
        formattedNow = now.strftime(datetime_format)
        dir = "/var/www/api/downloads/" + formattedNow
        dir_relative_to_url = "/downloads/" + formattedNow
        os.mkdir(dir)
        file_name = "source"

        url = request.args["url"]
        file_url = youtube_downloader.download(url, file_name, dir)
        subprocess.Popen(["/var/www/api/venv/bin/spleeter", "separate", "-p",
                      "spleeter:4stems", "-o", dir, file_url], cwd='/var/www/api/')

        cleanup("/var/www/api/downloads/")

        stems = {"vocals" : dir_relative_to_url + "/" + file_name + "/vocals.wav",
        "drums": dir_relative_to_url + "/" + file_name + "/drums.wav",
        "bass": dir_relative_to_url + "/" + file_name + "/bass.wav", 
        "other": dir_relative_to_url + "/" + file_name + "/other.wav"}
        return jsonify(stems), 200
    else:
        ret = {"error": "Missing parameters"}
        return jsonify(ret), 400


def cleanup(dir):
    now = datetime.now()
    for sub_dir in os.listdir(dir):
        try:
            dirDateTime = datetime.strptime(sub_dir, datetime_format)
        except Exception:
            continue
        difference = now - dirDateTime
        differenceInMin = divmod(difference.seconds, 60)[0]
        if differenceInMin > 5:
            try:
                shutil.rmtree(dir + "/" + sub_dir)
            except Exception:
                continue
