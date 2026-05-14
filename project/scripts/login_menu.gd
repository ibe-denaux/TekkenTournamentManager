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
	visibility_changed.connect(_on_visibility_changed)


func _on_login_confirm_button_pressed() -> void:
	var user_name: String = login_name_line_edit.text
	var result: String = await NetworkUtil.login(user_name, login_password_line_edit.text)
	if result == NetworkUtil.server_ok_response:
		MenuUtil.show_home_menu()
	login_response_label.text = result


func _on_login_cancel_button_pressed() -> void:
	MenuUtil.show_home_menu()


func _on_create_account_confirm_button_pressed() -> void:
	var user_name: String = create_account_name_line_edit.text
	var result: String = await NetworkUtil.create_account(user_name, create_account_password_line_edit.text)
	if result == NetworkUtil.server_ok_response:
		MenuUtil.show_home_menu()
	create_account_response_label.text = result


func _on_create_account_cancel_button_pressed() -> void:
	MenuUtil.show_home_menu()


func _on_tab_container_tab_changed(_tab: int) -> void:
	login_response_label.text = ""
	create_account_response_label.text = ""


func _on_visibility_changed() -> void:
	login_response_label.text = ""
	login_password_line_edit.text = ""
	create_account_response_label.text = ""
	create_account_password_line_edit.text = ""
	create_account_name_line_edit.text = ""
