extends Control

@export var level_one_scene_path: String

func _on_play_button_pressed() -> void:
	LevelManager.change_level(level_one_scene_path)
	hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
