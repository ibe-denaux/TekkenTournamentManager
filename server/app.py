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
tournament_info_file_name = THIS_FOLDER / "tournament_info.json"
tournament_info_lock_name = THIS_FOLDER / "tournament_info.json.lock"

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
    password = request.json[password_key] if password_key in request.json else ""
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


@app.route("/register", methods=["POST"])
def register():
    if not login()[status_key] == "ok":
        return {status_key: "Can't log in"}
    lock = FileLock(tournament_info_lock_name)
    with lock:
        with open(tournament_info_file_name, 'r') as fp:
            content = json.load(fp)
            if "participants" not in content:
                content["participants"] = {}
            content["participants"] = {request.json[username_key]: {"availability": request.json["availability"]}, "experience": request.json["experience"]}
        with open(tournament_info_file_name, 'w') as fp:
            json.dump(content, fp)
    return {status_key: "ok"}


@app.route("/get-tournament-info", methods=["GET"])
def get_tournament_info():
    lock = FileLock(tournament_info_lock_name)
    with lock:
        with open(tournament_info_file_name, 'r') as fp:
            content = json.load(fp)
        with open(tournament_info_file_name, 'w') as fp:
            if "registration_deadline" not in content:
                content["registration_deadline"] = ""
            if "start_date" not in content:
                content["start_date"] = ""
            return content


@app.route("/schedule-tournament", methods=["POST"])
def schedule_tournament():
    content = get_tournament_info()
    lock = FileLock(tournament_info_lock_name)
    with lock:
        with open(tournament_info_file_name, 'w') as fp:
            content["registration_deadline"] = request.json["registration_deadline"]
            content["start_date"] = request.json["start_date"]
            json.dump(content, fp)


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
    if not os.path.isfile(tournament_info_file_name):
        with open(tournament_info_file_name, 'w+') as fp:
            json.dump({}, fp)


if __name__ == '__main__':
    initialize()
    app.run()
