extends Node

var user_name: String:
	get:
		if user_name:
			return user_name
		return get_user_name()
	set(value):
		user_name = value
		set_user_name(value)
var server_address: String = "http://127.0.0.1:5000/"
var logged_in: bool = false

var server_ok_response: String = "ok"

var _save_game_path: String = "user://savegame.save"
var _user_name_key: String = "username"
var _status_key: String = "status"

var _http_request: HTTPRequest


func login(user: String = user_name, password: String = "") -> String:
	var data: String = JSON.stringify({"username": user, "password": password})
	var result: String = await _send_request("/login", HTTPClient.Method.METHOD_POST, data)
	if result == server_ok_response:
		logged_in = true
	return result


func create_account(user: String, password: String) -> String:
	var data: String = JSON.stringify({"username": user, "password": password})
	var result: String = await _send_request("/create-account", HTTPClient.Method.METHOD_POST, data)
	if result == server_ok_response:
		logged_in = true
	return result


func get_user_name() -> String:
	var data: Dictionary = _get_save_data()
	if _user_name_key in data:
		return data[_user_name_key]
	return ""


func set_user_name(new_user_name: String) -> void:
	var save_file = FileAccess.open(_save_game_path, FileAccess.WRITE)
	var data: Dictionary = {_user_name_key: new_user_name}
	save_file.store_line(JSON.stringify(data))


func _ready() -> void:
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	user_name = get_user_name()
	if user_name:
		login()


func _send_request(route: String = "/", method: HTTPClient.Method = HTTPClient.Method.METHOD_GET, data: String = "") -> String:
	var result = _http_request.request(NetworkUtil.server_address + route, ["Content-Type: application/json"], method, data)
	if result == ERR_BUSY:
		return "Server is busy"
	if result == ERR_CANT_CONNECT:
		return "Server is down"
	var response: Array = await _http_request.request_completed
	if response.size() > 3:
		var json = JSON.parse_string(response[3].get_string_from_utf8())
		if json and _status_key in json:
			return json[_status_key]
	return ""


func _get_save_data() -> Dictionary:
	var save_file = FileAccess.open(_save_game_path, FileAccess.READ)
	if not save_file:
		return {}
	var json_string = save_file.get_line()
	var json = JSON.new()

	# Check if there is any error while parsing the JSON string, skip in case of failure.
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return {}
	
	# Get the data from the JSON object.
	return json.data
