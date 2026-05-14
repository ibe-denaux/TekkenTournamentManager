extends MarginContainer

@export_group("Availability")
@export
var monday_checkbutton: CheckButton
@export
var tuesday_checkbutton: CheckButton
@export
var wednesday_checkbutton: CheckButton
@export
var thursday_checkbutton: CheckButton
@export
var friday_checkbutton: CheckButton
@export_group("Experience")
@export
var new_player_checkbutton: CheckButton
@export
var casual_player_checkbutton: CheckButton
@export
var veteran_player_checkbutton: CheckButton
@export_group("Result")
@export
var server_response_label: Label


func _on_submit_button_pressed() -> void:
	var availability: Dictionary = {
			"monday": monday_checkbutton.button_pressed,
			"tuesday": tuesday_checkbutton.button_pressed,
			"wednesday": wednesday_checkbutton.button_pressed,
			"thursday": thursday_checkbutton.button_pressed,
			"friday": friday_checkbutton.button_pressed,
		}
	var experience: int = int(casual_player_checkbutton.button_pressed) + int(veteran_player_checkbutton.button_pressed) * 2
	var result: String = await NetworkUtil.register(availability, experience)
	server_response_label.text = result
