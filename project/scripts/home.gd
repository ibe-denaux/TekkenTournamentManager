extends Control

@export_group("Buttons")
@export
var home_button: Control
@export
var register_button: Control
@export
var characters_button: Control
@export
var gamble_button: Control
@export
var shop_button: Control
@export
var rankings_button: Control
@export
var login_button: Control
@export
var logout_button: Control
@export_group("Menus")
@export
var loading_menu: Control
@export
var register_menu: Control
@export
var bracket_menu: Control
@export
var login_menu: Control
@export_group("PlayerInfo")
@export
var user_name_label: Label
@export
var next_match_label: Label
@export
var credits_label: Label


func _ready() -> void:
	loading_menu.show()
	_enable_buttons(false)
	var result = await NetworkUtil.login()
	if result == NetworkUtil.server_ok_response:
		_on_logged_in()
	else:
		_on_logged_out()
	NetworkUtil.user_logged_in.connect(_on_logged_in)
	NetworkUtil.user_logged_out.connect(_on_logged_out)
	_enable_buttons(true)


func _enable_buttons(enable: bool = true) -> void:
	home_button.disabled = not enable
	register_button.disabled = not enable
	gamble_button.disabled = not enable
	characters_button.disabled = not enable
	shop_button.disabled = not enable
	rankings_button.disabled = not enable
	login_button.disabled = not enable
	logout_button.disabled = not enable


func _on_logged_in() -> void:
	_on_home_button_pressed()
	login_button.hide()
	logout_button.show()
	user_name_label.text = NetworkUtil.get_user_name()


func _on_logged_out() -> void:
	login_menu.show()
	login_button.show()
	logout_button.hide()
	user_name_label.text = "Logged out"


func _on_register_button_pressed() -> void:
	register_menu.show()


func _on_home_button_pressed() -> void:
	bracket_menu.show()


func _on_login_button_pressed() -> void:
	login_menu.show()


func _on_logout_button_pressed() -> void:
	NetworkUtil.logout()
