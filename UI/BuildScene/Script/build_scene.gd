extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


func _on_ready_button_pressed() -> void:
	hide()


func _on_units_visibility_changed() -> void:
	if visible:
		pass
