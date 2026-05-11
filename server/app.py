import json
import os

from flask import Flask
from flask import request, Response
from flask_cors import CORS

from pathlib import Path
from filelock import FileLock

from cryptography.fernet import Fernet

THIS_FOLDER = Path(__file__).parent.resolve()

app = Flask(__name__)
CORS(app)

secret_key_file_name = THIS_FOLDER / "secret_key.txt"
player_info_file_name = THIS_FOLDER / "player_info.json"
player_info_lock_name = THIS_FOLDER / "player_info.json.lock"

status_key = "status"
username_key = "username"
password_key = "password"
cipher_key = "cipher"


@app.before_request
def handle_preflight():
    if request.method == "OPTIONS":
        res = Response()
        res.headers['X-Content-Type-Options'] = '*'
        return res


@app.route("/")
def hello_world():
    return "<p>Hello, World!</p>"


@app.route("/create-account", methods=["POST"])
def create_account():
    username = request.json[username_key]
    password = request.json[password_key]
    if not username:
        return {status_key: "Invalid username"}
    if not password:
        return {status_key: "Invalid password"}
    lock = FileLock(player_info_lock_name)
    with lock:
        with open(player_info_file_name, 'r') as fp:
            content = json.load(fp)
        if username in content:
            return {status_key: "Account already exists"}
        with open(player_info_file_name, 'w') as fp:
            content[username] = {password_key: password}
            json.dump(content, fp)
        app.logger.info('%s created account successfully', username)
    return login()


@app.route("/login", methods=["POST"])
def login():
    username = request.json[username_key]
    password = request.json[password_key]
    cipher = request.json[cipher_key]
    fernet = Fernet(app.secret_key.encode('utf-8'))
    if not password and cipher:
        password = fernet.decrypt(cipher).decode('utf-8')
    if not username:
        return {status_key: "Invalid username"}
    if not password:
        return {status_key: "Invalid password"}
    lock = FileLock(player_info_lock_name)
    with lock:
        with open(player_info_file_name, 'r') as fp:
            content = json.load(fp)
            if username not in content:
                return {status_key: "No Account"}
            player_info = content[username]
            if player_info[password_key] == password:
                app.logger.info('%s logged in successfully', username)
                return {status_key: "ok", cipher_key: fernet.encrypt(password.encode('utf-8')).decode('utf-8')}
            return {status_key: "Wrong password"}


def initialize():
    if not os.path.isfile(secret_key_file_name):
        with open(secret_key_file_name, 'w+') as fp:
            secret_key = Fernet.generate_key()
            fp.write(secret_key.decode("utf-8"))
    with open(secret_key_file_name, 'r') as fp:
        app.secret_key = fp.read()
    if not os.path.isfile(player_info_file_name):
        with open(player_info_file_name, 'w+') as fp:
            json.dump({}, fp)


if __name__ == '__main__':
    initialize()
    app.run()
