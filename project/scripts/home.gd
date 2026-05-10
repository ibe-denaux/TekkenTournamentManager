extends Control

@export_group("Dependencies")
@export
var http_request: HTTPRequest
@export
var bracket_menu: Control
@export
var login_menu: Control


func _on_home_button_pressed() -> void:
	bracket_menu.show()


func _on_login_button_pressed() -> void:
	login_menu.show()
