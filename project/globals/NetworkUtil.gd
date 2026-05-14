extends Node

var user_name: String:
	get:
		if user_name:
			return user_name
		return get_user_name()
	set(value):
		user_name = value
		set_user_name(value)
var server_address: String = "http://127.0.0.1:5000"
var logged_in: bool = false

var server_ok_response: String = "ok"

var _save_game_path: String = "user://savegame.save"
var _user_name_key: String = "username"
var _password_key: String = "password"
var _cipher_key: String = "cipher"
var _status_key: String = "status"
var _availability_key: String = "availability"
var _experience_key: String = "experience"

var _http_request: HTTPRequest

signal user_logged_in()
signal user_logged_out()


func create_account(user: String, password: String) -> String:
	var data: String = JSON.stringify({_user_name_key: user, _password_key: password, _cipher_key: _get_cipher()})
	var result: Dictionary = await _send_request("/create-account", HTTPClient.Method.METHOD_POST, data)
	return _handle_login(user, result)


func login(user: String = user_name, password: String = "") -> String:
	var data: String = JSON.stringify({_user_name_key: user, _password_key: password, _cipher_key: _get_cipher()})
	var result: Dictionary = await _send_request("/login", HTTPClient.Method.METHOD_POST, data)
	return _handle_login(user, result)


func logout() -> void:
	_set_save_data_entry(_cipher_key, "")
	logged_in = false
	user_name = ""
	user_logged_out.emit()


func register(availability: Dictionary, experience: int) -> String:
	var data: String = JSON.stringify({_user_name_key: get_user_name(), _cipher_key: _get_cipher(), _availability_key: availability, _experience_key: experience})
	var result: Dictionary = await _send_request("/register", HTTPClient.Method.METHOD_POST, data)
	return result[_status_key]


func get_user_name() -> String:
	var data: Dictionary = _get_save_data()
	if _user_name_key in data:
		return data[_user_name_key]
	return ""


func set_user_name(new_user_name: String) -> void:
	_set_save_data_entry(_user_name_key, new_user_name)


func _ready() -> void:
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	user_name = get_user_name()


func _send_request(route: String = "/", method: HTTPClient.Method = HTTPClient.Method.METHOD_GET, data: String = "") -> Dictionary:
	var headers = ["Content-Type: application/json", "Access-Control-Allow-Methods: POST, GET, OPTIONS"]
	var result = _http_request.request(server_address + route, headers, method, data)
	if result == ERR_BUSY:
		return {_status_key: "Server is busy"}
	if result == ERR_CANT_CONNECT:
		return {_status_key: "Server is down"}
	if result != OK:
		return {_status_key: "Server error"}
	var response: Array = await _http_request.request_completed
	if response.size() > 3:
		var json = JSON.parse_string(response[3].get_string_from_utf8())
		if json:
			return json
	return {_status_key: "Server error"}


func _handle_login(user: String, result: Dictionary) -> String:
	if not result:
		push_warning("no valid login result")
		return "login failed"
	if result[_status_key] == server_ok_response:
		if _cipher_key in result:
			_set_save_data_entry(_cipher_key, result[_cipher_key])
		logged_in = true
		NetworkUtil.set_user_name(user)
		user_logged_in.emit()
	return result[_status_key]


func _get_cipher() -> String:
	var data: Dictionary = _get_save_data()
	if _cipher_key in data:
		return data[_cipher_key]
	return ""


func _get_save_data() -> Dictionary:
	var save_file = FileAccess.open(_save_game_path, FileAccess.READ)
	if not save_file:
		return {}
	var json_string = save_file.get_line()
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}
	return json.data


func _set_save_data_entry(key: String, value: String) -> void:
	var save_data: Dictionary = _get_save_data()
	var save_file = FileAccess.open(_save_game_path, FileAccess.WRITE)
	save_data[key] = value
	save_file.store_line(JSON.stringify(save_data))
