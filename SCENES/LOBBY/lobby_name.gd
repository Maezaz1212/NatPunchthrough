extends Control

@export var controller := false
var controller_id := 0
func _on_line_edit_text_changed(new_text):
	if !controller:
		GameManager.player_name_keyboard = new_text
	else:
		GameManager.player_names_controller[controller_id] = new_text
