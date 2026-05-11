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


func _ready() -> void:
	var user_name: String = NetworkUtil.get_user_name()
	if user_name:
		login_name_line_edit.text = user_name


func _on_login_confirm_button_pressed() -> void:
	var user_name: String = login_name_line_edit.text
	var result: String = await NetworkUtil.login(user_name, login_password_line_edit.text)
	if result == NetworkUtil.server_ok_response:
		NetworkUtil.set_user_name(user_name)
	login_response_label.text = result


func _on_login_cancel_button_pressed() -> void:
	hide()


func _on_create_account_confirm_button_pressed() -> void:
	var user_name: String = create_account_name_line_edit.text
	var result: String = await NetworkUtil.create_account(user_name, create_account_password_line_edit.text)
	if result == NetworkUtil.server_ok_response:
		NetworkUtil.set_user_name(user_name)
	create_account_response_label.text = result


func _on_create_account_cancel_button_pressed() -> void:
	hide()


func _on_tab_container_tab_changed(_tab: int) -> void:
	login_response_label.text = ""
	create_account_response_label.text = ""
