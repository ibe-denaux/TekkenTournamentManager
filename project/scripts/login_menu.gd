extends CenterContainer


@export
var login_name_line_edit: LineEdit
@export
var login_password_line_edit: LineEdit
@export
var create_account_name_line_edit: LineEdit
@export
var create_account_password_line_edit: LineEdit
@export
var login_response_label: Label
@export
var create_account_response_label: Label
@export
var http_request: HTTPRequest


func _on_login_confirm_button_pressed() -> void:
	var json = JSON.stringify({"username": login_name_line_edit.text, "password": login_password_line_edit.text})
	http_request.request_completed.connect(_on_login_request_completed, CONNECT_ONE_SHOT)
	http_request.request(NetworkUtil.server_address + "/login", ["Content-Type: application/json"], HTTPClient.METHOD_POST, json)


func _on_login_cancel_button_pressed() -> void:
	hide()


func _on_create_account_confirm_button_pressed() -> void:
	var json = JSON.stringify({"username": create_account_name_line_edit.text, "password": create_account_password_line_edit.text})
	http_request.request_completed.connect(_on_create_account_request_completed, CONNECT_ONE_SHOT)
	http_request.request(NetworkUtil.server_address + "/create-account", ["Content-Type: application/json"], HTTPClient.METHOD_POST, json)


func _on_create_account_cancel_button_pressed() -> void:
	hide()


func _on_login_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json:
		login_response_label.text = json["status"]


func _on_create_account_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.parse_string(body.get_string_from_utf8())
	if json:
		create_account_response_label.text = json["status"]
