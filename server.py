from flask import Flask, send_file
import subprocess
import time
import os

app = Flask(__name__)

IMAGE_PATH = "latest.jpg"

def capture_image():
    try:
        os.remove(IMAGE_PATH)
    except FileNotFoundError:
        pass

    cmd = [
        "rpicam-still",
        "-o", IMAGE_PATH,
        "--width", "1440",
        "--height", "1440",
        "-n"
    ]
    subprocess.run(cmd, check=True)

@app.route("/capture", methods=["POST", "GET"])
def capture_route():
    capture_image()
    return send_file(IMAGE_PATH, mimetype="image/jpeg")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
