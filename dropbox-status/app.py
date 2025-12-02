from flask import Flask, jsonify
from dropbox_status import get_dropbox_status

app = Flask(__name__)

@app.get("/status")
def status():
    return jsonify(get_dropbox_status())

@app.get("/")
def root():
    return jsonify({"message": "Dropbox status API"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8006)
