extends Control

@export var level_one_scene_path: String
const TITLE_THEME = preload("res://Assets/Audio/Music/pixeljam demo 1 - title theme.wav")


func _ready() -> void:
	%Music.stream = TITLE_THEME
	%Music.play()
	
func _on_play_button_pressed() -> void:
	LevelManager.change_level(level_one_scene_path)
	hide()


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_options_button_pressed() -> void:
	%OptionsMenu.show()
